// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

#if os(macOS)
import Darwin
#elseif os(linux)
#error("not yet implemented")
#endif

public struct _WhoEntry {
  public let user: String
  public let line: String // Das Terminal (z.B. ttys001)
  public let host: String // Hostname bei SSH
  public let time: Date
}


public struct _who {
  public static func fetchWhoEntries() -> [_WhoEntry] {
    var results: [_WhoEntry] = []
    
    // Verbindung zur utmpx-Datenbank öffnen
    setutxent()
    defer {
      // immer Datenbank schließen
      endutxent()
    }

    // Durch die Einträge loopen
    // getutxent() gibt einen UnsafeMutablePointer<utmpx>? zurück
    while let entryPtr = getutxent() {
      let entry = entryPtr.pointee
      
      // Wir wollen nur "echte" User-Prozesse (kein Boot oder Shutdown)
      if entry.ut_type == USER_PROCESS {
        
        // C-Strings in Swift-Strings umwandeln
        let user = withUnsafePointer(to: entry.ut_user) {
          $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: entry.ut_user)) {
            String(cString: $0)
          }
        }
        
        let line = withUnsafePointer(to: entry.ut_line) {
          $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: entry.ut_line)) {
            String(cString: $0)
          }
        }
        
        let host = withUnsafePointer(to: entry.ut_host) {
          $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: entry.ut_host)) {
            String(cString: $0)
          }
        }
        
        // Zeitstempel konvertieren (ut_tv sind Sekunden)
        let date = Date(timeIntervalSince1970: TimeInterval(entry.ut_tv.tv_sec))
        
        results.append(_WhoEntry(user: user, line: line, host: host, time: date))
      }
    }
    
    return results
  }
}
