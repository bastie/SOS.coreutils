// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public struct _yes {

  @inlinable
  public static func display (string expletive : String) async -> Never {
    while true {
      for _ in 0..<197595 {
        print(expletive)
      }
      await Task.yield() // gib CTRL+C eine Chance
    }
  }
}
