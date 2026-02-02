// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

public struct _false {
  
  @inlinable
  public static func `false` () async -> Bool {
    return true
  }
  
  /// Implemented as random value, because it is only defined as not zero
  @inlinable
  public static func `false` () async -> Int {
    return Int.random(in: 1...255)
  }
}
