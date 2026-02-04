// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

#if canImport(Darwin)
import Darwin
#else
#error("not yet implemented")
#endif

public class _id {
  
  public init(){}
  
  let uid : uid_t = {
    getuid()
  }()
  let gid : gid_t = {
    getgid()
  }()

  public var whoami: String {
    getpwuid(uid).map { String(cString: $0.pointee.pw_name) } ?? "unknown"
  }
  
  /// Holt alle zusätzlichen Gruppen-IDs des aktuellen Users
  public func getSupplementalGroups() -> [gid_t] {
    // 1. Fragen, wie viele Gruppen es gibt
    let count = getgroups(0, nil)
    if count <= 0 { return [] }
    
    // 2. Buffer für die Gruppen-IDs reservieren
    var groupList = [gid_t](repeating: 0, count: Int(count))
    
    // 3. Den Buffer befüllen
    let actualCount = getgroups(count, &groupList)
    return Array(groupList.prefix(Int(actualCount)))
  }

}
