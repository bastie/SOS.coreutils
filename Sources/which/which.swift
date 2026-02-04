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
    switch (check, quiet) {
    case (nil, _) :
      // only error so rc is non zero
      Foundation.exit (EXIT_FAILURE)
    case (_, true) :
      // if one error rc is non zero
      for next in check! {
        if !next.ok {
          Foundation.exit (EXIT_FAILURE)
        }
      }
      // all ok rc is zero
      Foundation.exit(EXIT_SUCCESS)
    default:
      var rc = EXIT_SUCCESS
      for next in check! {
        if next.ok {
          print (next.path)
        }
        else {
          rc = EXIT_FAILURE
        }
      }
      Foundation.exit (rc)
    }
  }
}

