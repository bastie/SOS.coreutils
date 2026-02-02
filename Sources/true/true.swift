// SPDX-License-Identifier: 0BSD OR EUPL-1.2 OR Apache-2.0
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation

@main
public struct True {
  public static func main () async throws {
    let t : Int = await _true.true()
    Foundation.exit(Int32(t))
  }
}
