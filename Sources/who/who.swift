// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation

@main
public struct who {
  
  public static func main () async {
    let entries = _who.fetchWhoEntries()
    let whoDateFormatter = DateFormatter()
    whoDateFormatter.dateFormat = "dd MMM HH:mm" // TODO: i18n
    
    for e in entries {
      let printableDate = whoDateFormatter.string(from: e.time)
      // Format: user     line           time           (host)
      let hostStr = e.host.isEmpty ? "" : "(\(e.host))"
      print("\(e.user.padding(toLength: 16, withPad: " ", startingAt: 0)) \(e.line.padding(toLength: 12, withPad: " ", startingAt: 0)) \(printableDate) \(hostStr)")
    }
  }
  
  
  
}
