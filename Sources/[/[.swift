
import core
import Foundation

@main
struct `[` {
  public static func main () async {
    // --- 4. START ---
    /*
     var rawArgs = Array(CommandLine.arguments.dropFirst())
     */
    // Ganz unten bei der Argument-Verarbeitung:
    var rawArgs = Array(CommandLine.arguments.dropFirst())
    if rawArgs.first == "[" { rawArgs.removeFirst() } // Falls 'swift run [' das '[' mitliefert
    if rawArgs.last == "]" { rawArgs.removeLast() }
    
    var debugMode = false
    if let idx = rawArgs.firstIndex(of: "--tree") {
      debugMode = true
      rawArgs.remove(at: idx)
    }
    if rawArgs.last == "]" { rawArgs.removeLast() }
    
    let tokens = `_[`.Lexer().tokenize(rawArgs)
    let parser = `_[`.Parser(tokens: tokens, debug: debugMode)
    
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
