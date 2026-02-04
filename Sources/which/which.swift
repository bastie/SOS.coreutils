// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation
import ArgumentParser // is too much but provides usage and help by default

@main
public struct yes : AsyncParsableCommand {
  
  public init(){}
  
  public static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "which",
      abstract: "locate a program in your file path",
      discussion:
      """
      Note: Some shell use incompatible build in implementations. 
      """,
      version: "1.0.0"
    )
  }
  
  
  @Flag(name: [.customShort("a")], help: "List all programs instead of only first.")
  var all = false
  
  @Flag(name: [.customShort("s")], help: "Quiet mode returns only zero if program found.")
  var quiet = false
  

  @Argument(help: "Looking for this program.")
  var program: [String] = []
  
  public func run() async throws {
    let check = _which.locate(lookingFor: program, stopAtFirst: !all)
    var results : (success : Int, sucks : Int) = (0,0)

    switch (check, quiet) {
    case (nil, _) :
      // only error so rc is OpenBSD like 2
      Foundation.exit (2)
    case (_, true) :
      var results : (success : Int, sucks : Int) = (0,0)
      for next in check! {
        if next.ok {
          results.success += 1
        }
        else {
          results.sucks += 1
        }
      }
    default:
      for next in check! {
        if next.ok {
          print (next.path)
          results.success += 1
        }
        else {
          results.sucks += 1
        }
      }
    }
    // OpenBSD like return codes
    switch results {
    case (0, _) :
      Foundation.exit (2) // only errors
    case (_,0) :
      Foundation.exit (0) // no errors
    default :
      Foundation.exit (1) // some errors
    }

  }
}

