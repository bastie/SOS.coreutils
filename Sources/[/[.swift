// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation

@main
struct Bracket {
  public static func main () async {
    var rawArgs = Array(CommandLine.arguments.dropFirst())
    if rawArgs.first == "[" { rawArgs.removeFirst() }
    if rawArgs.last == "]" { rawArgs.removeLast() }
    
    var debugMode = false
    if let idx = rawArgs.firstIndex(of: "--tree") {
      debugMode = true
      rawArgs.remove(at: idx)
    }
    
    let tokens = _bracket.Lexer().tokenize(rawArgs)
    let parser = _bracket.Parser(tokens: tokens, debug: debugMode)
    
    do {
      let result = try parser.parseOR()
      if debugMode { print("── Result: \(result)") }
      exit(result ? 0 : 1)
    } catch {
      print("Syntax Error")
      exit(2)
    }
  }
}
