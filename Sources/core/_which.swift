// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public struct _which {
  
  public static func locate (lookingFor programs: [String], stopAtFirst : Bool = true) -> [(path : String, ok : Bool)]? {
    var result : [(String, Bool)] = []
    
    let system = FileManager.default
    if let paths = directories() {
      
      for program in programs {
        
        var found = false
        for path in paths {
          let qualifiedName = path.reversed().starts(with: "/") ? path + program : path + "/" + program
          if system.fileExists(atPath: qualifiedName) && system.isExecutableFile(atPath: qualifiedName) {
            result.append((qualifiedName, true))
            found = true
          }
          if stopAtFirst && found {
            break
          }
        } // all paths
        if !found {
          result.append((program, false))
        }
      } // all programs
      
      return result
    }
    else {
      return nil
    }
    
  }
  
  static func directories (from env : String = "PATH", by separator : String = ":") -> [String]? {
    if let pathValue = ProcessInfo.processInfo.environment["PATH"] {
      let paths = pathValue.components(separatedBy: separator)
      return paths
    } else {
      return nil
    }
  }
}
