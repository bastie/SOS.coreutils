// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public struct _head {
  
  public static func printHead (from files : [String], count limit : Int, noBytes : Bool = true, with header : Bool = false) async -> [_FileHeadResult]  {
    var result : [_FileHeadResult] = []
    
    // rollout for first so the empty line can be printed before next line without special test
    for file in files[0..<1] {
      var fileError = false
      var toPrint : [UInt8] = []
      if header {
        let data = "==> \(URL(filePath: file).lastPathComponent) <==\n".data(using: .utf8)!
        toPrint.append(contentsOf: [UInt8](data))
      }
      do {
        toPrint.append(contentsOf: try getHead(filename: file, limit: limit, lines: noBytes))
      }
      catch {
        fileError = true
        let errorMessage = "\(URL(filePath: file).lastPathComponent) not readable\n".data(using: .utf8)!
        toPrint = [UInt8](errorMessage)
      }
      result.append(_FileHeadResult(filename: file, error: fileError, output: Data(toPrint)))
    }
    // let build in check of file array size
    for file in files[1...] {
      var fileError = false
      var toPrint : [UInt8] = []
      if header {
        let data = "\n==> \(URL(filePath: file).lastPathComponent) <==\n".data(using: .utf8)!
        toPrint.append(contentsOf: [UInt8](data))
      }
      do {
        toPrint.append(contentsOf: try getHead(filename: file, limit: limit, lines: noBytes))
      }
      catch {
        fileError = true
        let errorMessage = "\(URL(filePath: file).lastPathComponent) not readable\n".data(using: .utf8)!
        toPrint = [UInt8](errorMessage)
      }
      result.append(_FileHeadResult(filename: file, error: fileError, output: Data(toPrint)))
    }
    return result
  }
  
  ///
  /// - Parameters:
  ///   - filename to print
  ///   - limit to print
  ///   - lines if true or `bytes` if false
  @inline(__always)
  private static func getHead (filename : String, limit : Int, lines : Bool) throws -> [UInt8] {
    let handle = try FileHandle(forReadingFrom: URL (filePath: filename))
    defer {
      try? handle.close()
    }
    
    var result : [UInt8] = [] // TODO: Data to UInt-Array to Data = to much convert
    var count = 0
    
    if lines {
      // Wir lesen die Daten blockweise oder zeilenweise
      while count < limit, let data = try? handle.read(upToCount: 1024), !data.isEmpty {
        let array = data.split(separator: 0x0A)
        for next in array {
          guard count < limit else {
            break
          }
          result.append(contentsOf: next)
          result.append(0x0A)
          count += 1
        }
      }
    }
    else {
      while count < limit, let data = try? handle.read(upToCount: 1024), !data.isEmpty {
        for next in [UInt8](data) {
          guard count < limit else {
            break
          }
          result.append(next)
            count += 1
        }
      }
    }
    
    return result
  }
  
  public static func printHeadFromStdIn () {
    fatalError("not yet implemented")
  }
}


public struct _FileHeadResult {
  public let filename : String
  public let error : Bool
  public let output : Data
}
