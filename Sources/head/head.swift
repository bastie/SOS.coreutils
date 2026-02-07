// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation
import ArgumentParser

/// ```head```filter the content to the result of count lines, bytes or chars
@main
struct head : AsyncParsableCommand {
  
  static let PRINT_LINES = -1
  
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "head",
      abstract: "Print the first lines of each FILE to standard output.",
      discussion:
      """
      """,
      version: "1.0.0"
    )
  }

  @Option(name: [.customShort("c"), .customLong("bytes")], help: "Print bytes of file.")
  var bytes : Int = PRINT_LINES  // GNU accept values lesser than zero
  
  @Option(name: [.customShort("n"), .customLong("lines")], help: "Print lines of file.")
  var lines : UInt = 10  // GNU accept values lesser than zero
  
  @Flag(name: [.customShort("q"), .customLong("quiet"), .customLong("silent")], help: "Print no file header names if more than one file is printed")
  var quiet = false

  @Flag(name: [.customShort("v"), .customLong("verbose")], help: "Print file names also if only file header is needed")
  var printAlwaysFileHeader = false
  
  @Argument(help: "files")
  var file: [String] = []
  
  var BSD : Bool { return !(CommandLine.arguments[0] == "ghead") }
  
  func run() async throws {
    var rc : Int32 = 0

    // print header or not
    var header = file.count > 1
    header = quiet ? false : header
    header = printAlwaysFileHeader ? true : header
    
    // call BO
    let result : [_FileHeadResult] = await _head.printHead(from: file, count: (head.PRINT_LINES == bytes ? Int(lines) : bytes), noBytes: head.PRINT_LINES == bytes, with: header)

    // do not use String, because it can be an non UTF-8 conform byte array
    for next in result {
      if next.error {
        let prg = "\(URL(filePath: CommandLine.arguments[0]).lastPathComponent): ".data(using: .utf8)!
        try? FileHandle.standardOutput.write(contentsOf: prg)
        try? FileHandle.standardOutput.write(contentsOf: next.output)
        rc = 1
      }
      else {
        try? FileHandle.standardOutput.write(contentsOf: next.output)
      }
    }

    Foundation.exit(rc)
  }
}
