// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation
#if canImport(Darwin)
import Darwin
#else
#error("not yet implemented")
#endif

extension _wc {
  
  @inline(__always)
  static func countNewlines(baseAddr: Int, start: Int, end: Int) -> Int {
    var count = 0
    // Wir starten als Mutable, damit die Typen von memchr ohne Cast passen
    guard var currentPtr = UnsafeMutableRawPointer(bitPattern: baseAddr)?.advanced(by: start) else { return 0 }
    let endPtr = currentPtr.advanced(by: end - start)
    
    while currentPtr < endPtr {
      let remaining = endPtr - currentPtr
      // memchr ist in Apple's LibSystem extrem auf NEON/SIMD optimiert
      if let found = memchr(currentPtr, 10, remaining) {
        count += 1
        currentPtr = found.advanced(by: 1)
      } else {
        break
      }
    }
    return count
  }
  
  @inline(__always)
  internal func lineCount (for file: String) async -> Int {

    let fd = open(file, O_RDONLY)
    guard fd >= 0 else {
      print("Could not open file.")
      exit(1)
    }
    defer { close(fd) }
    
    // Dateigröße ermitteln
    var stat = stat()
    guard fstat(fd, &stat) == 0 else {
      print("Could not stat file.")
      exit(1)
    }
    let fileSize = Int(stat.st_size)
    
    // Adaptive Strategie
    let physMem = ProcessInfo.processInfo.physicalMemory
    let windowSize = (Double(fileSize) > Double(physMem) * 0.85) ? 2 * 1024 * 1024 * 1024 : fileSize
    
    let numCores = ProcessInfo.processInfo.activeProcessorCount
    let chunkSize = 32 * 1024 * 1024
    
    var grandTotal = 0
    var offset = 0
    
    while offset < fileSize {
      let mapSize = min(windowSize, fileSize - offset)
      
      guard let addr = mmap(nil, mapSize, PROT_READ, MAP_SHARED, fd, off_t(offset)),
            addr != MAP_FAILED else {
        offset += mapSize
        continue
      }
      
      // Kernel Hinweise
      madvise(addr, mapSize, MADV_SEQUENTIAL)
      madvise(addr, mapSize, MADV_WILLNEED)
      
      // Pointer zu Int (Sendable Hack für Swift 6)
      let baseAddrInt = Int(bitPattern: addr)
      
      // Parallelisierung
      let windowTotal = await withTaskGroup(of: Int.self) { group in
        let totalChunks = (mapSize + chunkSize - 1) / chunkSize
        
        // Einfache Verteilung der Chunks auf Cores
        let chunksPerCore = totalChunks / numCores
        let remainder = totalChunks % numCores
        
        for coreIdx in 0..<numCores {
          // Jeder Core bekommt seinen festen Bereich berechnet -> Keine Atomics nötig!
          let startChunk = coreIdx * chunksPerCore + min(coreIdx, remainder)
          let endChunk = startChunk + chunksPerCore + (coreIdx < remainder ? 1 : 0)
          
          if startChunk < endChunk {
            group.addTask {
              var localCount = 0
              for chunkIdx in startChunk..<endChunk {
                let chunkStart = chunkIdx * chunkSize
                let chunkEnd = min(chunkStart + chunkSize, mapSize)
                // Aufruf unserer optimierten Engine
                localCount += _wc.countNewlines(baseAddr: baseAddrInt, start: chunkStart, end: chunkEnd)
              }
              return localCount
            }
          }
        }
        
        var total = 0
        for await count in group {
          total += count
        }
        return total
      }
      
      grandTotal += windowTotal
      
      madvise(addr, mapSize, MADV_DONTNEED)
      munmap(addr, mapSize)
      offset += mapSize
    }
    
    return grandTotal
  }
}
