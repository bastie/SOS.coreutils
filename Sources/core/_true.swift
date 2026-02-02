// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

public struct _true {
  
  @inlinable
  public static func `true` () async -> Bool {
    return true
  }
  
  @inlinable
  public static func `true` () async -> Int {
    return 0
  }
}
