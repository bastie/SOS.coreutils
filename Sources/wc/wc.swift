// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation
import ArgumentParser

@main
struct wc : AsyncParsableCommand {
  
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "wc",
      abstract: "count byte, char, word, lines, max line length characteristics of file",
      discussion:
      """
      """,
      version: "0.1.0"
    )
  }
  
  @Flag(name: [.customShort("c")], help: "Count bytes of file.")
  var bytes = false
  
  @Flag(name: [.customShort("m")], help: "Count multibyte characters of file.")
  var characters = false
  
  @Flag(name: [.customShort("L")], help: "Count longest multibyte characters line of file.")
  var longestLine = false

  @Flag(name: [.customShort("l")], help: "Count lines of file.")
  var lines = false
  
  @Flag(name: [.customShort("w")], help: "Count words of file.")
  var words = false
  
  @Argument(help: "files")
  var file: [String] = []
  
  var BSD : Bool { return !(CommandLine.arguments[0] == "gwc") }

  func run() async throws {
    guard file.count > 0 else {
      print("CLI not supported")
      Foundation.exit(1)
    }

    let results = processPerFile(files: file)
    printResult(results: results)

  }
  
  func processPerFile (files : [String]) -> [_WCResult] {
    var result : [_WCResult] = []
    for file in files {
      result.append(try! _wc().processFile(at: file))
    }
    
    return result
  }
  
  /// Print results
  /// - Note: FreeBSD man page describe that only last flag of `m` and `c` wins. NetBSD do it also (today without note in manpage - send an issue). But OpenBSD do it like GNU coreutils and also allows both. This implementation accept both Flags and print the results for both.
  func printResult (results : [_WCResult]) {
    // build dynamic the string format
    
    // how much results expected?
    var expectedResultCounts : Int {
      var count = 0
      count += bytes ? 1 : 0
      count += characters ? 1 : 0
      count += words ? 1 : 0
      count += lines ? 1 : 0
      count += longestLine ? 1 : 0
      count = 0 == count ? 3 : count
      return count
    }
    
    // build for every of N expected result a placeholder
    var format : String {
      var formatString = BSD ? " " : ""
      for _ in 0..<expectedResultCounts {
        formatString.append(BSD ? "%7@ " : "%4@ ") // number values only as description, because ignored by Swift with @
      }
      formatString.append("%@")
      return formatString
    }
    // helper because %7@ is same as %@
    let pad = { (text: String) -> String in
      return String(repeating: " ", count: max(0, (BSD ? 7 : 4) - text.count)) + text
    }
    
    for result in results {
      // we have the string format, now we build an array of expected result
      var expectedResult : [String] {
        
        var expected : [String] = []
        if lines { expected.append(pad("\(result.lines)")) }
        if words { expected.append(pad("\(result.words)")) }
        if bytes { expected.append(pad("\(result.bytes)")) }
        if characters { expected.append(pad("\(result.charachters)")) }
        if longestLine { expected.append(pad("\(result.maxlinelength)")) }
        if 0 == expected.count {
          expected.append(pad("\(result.lines)"))
          expected.append(pad("\(result.words)"))
          expected.append(pad("\(result.bytes)"))
        }
        expected.append(result.filename ?? "")
        return expected
      }
      // bring both together the string format and the values
      print (String (format: format, arguments: expectedResult))
    }
    
    // if we need a total sum calculate and collect the expected total
    if results.count > 1 {
      var totalLines : Int = 0
      var totalWords : Int = 0
      var totalBytes : Int = 0
      var totalCharacters : Int = 0
      var maxLengthOfLine : Int = 0

      for result in results {
        totalLines += result.lines
        totalWords += result.words
        totalCharacters += result.charachters
        totalBytes += result.bytes
        if maxLengthOfLine < result.maxlinelength {
          maxLengthOfLine = result.maxlinelength
        }
      }
      
      var expectedResult : [String] {
        
        var expected : [String] = []
        if lines { expected.append(pad("\(totalLines)")) }
        if words { expected.append(pad("\(totalWords)")) }
        if bytes { expected.append(pad("\(totalBytes)")) }
        if characters { expected.append(pad("\(totalCharacters)")) }
        if longestLine { expected.append(pad("\(maxLengthOfLine)")) }
        if 0 == expected.count {
          expected.append(pad("\(totalLines)"))
          expected.append(pad("\(totalWords)"))
          expected.append(pad("\(totalBytes)"))
        }
        expected.append("total")
        return expected
      }
      print (String (format: format, arguments: expectedResult))
    }
  }
}
