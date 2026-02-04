// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public class _MD5 {
  
  public init(){}
  
  private var sA: UInt32 = 0x67452301
  private var sB: UInt32 = 0xefcdab89
  private var sC: UInt32 = 0x98badcfe
  private var sD: UInt32 = 0x10325476
  
  private var buffer = Data()
  private var totalLength: UInt64 = 0
  
  // Rotationsbeträge
  private let S: [UInt32] = [
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
  ]
  
  // Die 64 Konstanten (K) direkt als Hex-Werte
  private let K: [UInt32] = [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
  ]
  
  public func update(with data: Data) {
    totalLength += UInt64(data.count)
    buffer.append(data)
    while buffer.count >= 64 {
      process(block: buffer.prefix(64))
      buffer.removeFirst(64)
    }
  }
  
  public func finalize() -> String {
    let bitLength = totalLength * 8
    buffer.append(0x80)
    
    while (buffer.count % 64) != 56 {
      buffer.append(0)
    }
    
    let lenBytes = bitLength.littleEndian
    withUnsafeBytes(of: lenBytes) { buffer.append(contentsOf: $0) }
    
    // Verarbeite den Buffer, bis er leer ist
    while buffer.count >= 64 {
      let chunk = buffer.prefix(64)
      process(block: chunk)
      buffer.removeFirst(64)
    }
    
    // ... Hex-Export ...
  
    return [sA, sB, sC, sD].map { reg in
      let bytes = withUnsafeBytes(of: reg.littleEndian) { Data($0) }
      return bytes.map { String(format: "%02x", $0) }.joined()
    }.joined()
  }
  
  private func process(block: Data) {
    var M = [UInt32](repeating: 0, count: 16)
    block.withUnsafeBytes { raw in
      for i in 0..<16 {
        M[i] = raw.load(fromByteOffset: i * 4, as: UInt32.self).littleEndian
      }
    }
    
    var a = sA, b = sB, c = sC, d = sD
    
    for j in 0..<64 {
      var f: UInt32, g: Int
      if j < 16 {
        f = (b & c) | (~b & d); g = j
      } else if j < 32 {
        f = (d & b) | (~d & c); g = (5 * j + 1) % 16
      } else if j < 48 {
        f = b ^ c ^ d; g = (3 * j + 5) % 16
      } else {
        f = c ^ (b | ~d); g = (7 * j) % 16
      }
      
      let sum = a &+ f &+ K[j] &+ M[g]
      let rotated = (sum << S[j]) | (sum >> (32 - S[j]))
      let temp = b &+ rotated
      
      a = d; d = c; c = b; b = temp
    }
    sA &+= a; sB &+= b; sC &+= c; sD &+= d
  }
}
