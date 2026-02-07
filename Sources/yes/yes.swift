// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import ArgumentParser // is too much but provides usage and help by default

@main
public struct yes : AsyncParsableCommand {
  
  public init(){}
  
  public static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "yes",
      abstract: "endless repeat print of expletive",
      discussion:
      """
      """,
      version: "1.0.0"
    )
  }

  
  @Argument(help: "The expletive to print")
  var message: String = "y"
  
  public func run() async throws {
    await _yes.display(string: message)
  }
}

