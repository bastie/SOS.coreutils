// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation
import Darwin

public struct _bracket {
  
  // --- 1. TOKENS ---
  public enum Token: Equatable, Sendable {
    case number(Int)
    case string(String)
    case op(String)
    case openParen
    case closeParen
    case logicalAnd
    case logicalOr
  }
  
  enum ParseError: Error, Equatable {
    case unexpectedToken(Token?)
    case missingClosingParenthesis
    case invalidComparison
  }
  
  // --- 2. LEXER ---
  public struct Lexer {
    public init (){}
    
    func resolve(_ input: String) -> String {
      let pattern = #"\$\{(.+)\}|\$(.+)"#
      guard let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
        return input
      }
      let varName = (1...2).compactMap { i -> String? in
        guard match.range(at: i).location != NSNotFound else { return nil }
        return String(input[Range(match.range(at: i), in: input)!])
      }.first ?? ""
      return ProcessInfo.processInfo.environment[varName] ?? ""
    }
    
    public func tokenize(_ args: [String]) -> [Token] {
      return args.map { arg in
        let s = resolve(arg)
        switch s {
        case "(": return .openParen
        case ")": return .closeParen
        case "-a": return .logicalAnd
        case "-o": return .logicalOr
        case "!":  return .op("!")
          // HIER: Explizite Prüfung für Vergleichs-Operatoren
        case "=", "!=", "-eq", "-ne", "-gt", "-lt", "-ge", "-le":
          return .op(s)
          // Alles andere mit Bindestrich (wie -f, -u)
        case let x where x.hasPrefix("-"):
          return .op(x)
        case let x where Int(x) != nil:
          return .number(Int(x)!)
        default:
          return .string(s)
        }
      }
    }
  }
  
  // --- 3. PARSER ---
  public class Parser {
    var tokens: [Token]
    var depth = 0
    var debugMode = false
    
    public init(tokens: [Token], debug: Bool = false) {
      self.tokens = tokens
      self.debugMode = debug
    }
    
    private func log(_ message: String) {
      if debugMode {
        let prefix = String(repeating: "  │ ", count: depth)
        print("\(prefix)── \(message)")
      }
    }
    
    func consume() -> Token? {
      guard !tokens.isEmpty else { return nil }
      return tokens.removeFirst()
    }
    
    public func parseOR() throws -> Bool {
      log("OR-Level Start")
      var left = try parseAND()
      
      while tokens.first == .logicalOr {
        _ = consume() // -o entfernen
        log("OR Operator found")
        let right = try parseAND()
        left = left || right
      }
      return left
    }
    
    func parseAND() throws -> Bool {
      log("AND-Level Start")
      depth += 1; defer { depth -= 1 }
      
      var left = try parseUnary() // Hier wird -u /usr/bin/sudo verarbeitet
      
      while let next = tokens.first, next == .logicalAnd {
        _ = consume() // -a entfernen
        log("AND Operator found (-a)")
        let right = try parseUnary() // Hier wird bastie = bastie verarbeitet
        left = left && right
      }
      return left
    }
    
    func parseUnary() throws -> Bool {
      if tokens.first == .op("!") {
        _ = consume()
        return try !parseUnary()
      }
      return try parsePrimary()
    }

    func parsePrimary() throws -> Bool {
      guard let firstToken = tokens.first else { throw ParseError.unexpectedToken(nil) }
      log("Primary: \(firstToken)")
      
      // 1. Klammern
      if firstToken == .openParen {
        _ = consume()
        let res = try parseOR()
        guard let next = consume(), next == .closeParen else {
          throw ParseError.missingClosingParenthesis
        }
        log("Closed Parenthesis") // <--- Das macht den Baum komplett!
        return res
      }

      // 2. Unäre Tests (-u, -f, etc.)
      let unaryFlags = ["-f", "-d", "-u", "-g", "-t", "-z", "-n"]
      if case .op(let flag) = firstToken, unaryFlags.contains(flag) {
        _ = consume()
        guard let pathToken = consume() else { throw ParseError.invalidComparison }
        let path = getStringValue(from: pathToken)
        log("SystemCheck: \(flag) on \(path)")
        return performSystemCheck(flag: flag, path: path)
      }
      
      // 3. Binärer Vergleich (Zuerst schauen, dann konsumieren!)
      // Wir nehmen das erste Token als linke Seite
      let leftToken = consume()!
      let leftVal = getStringValue(from: leftToken)
      
      // Jetzt prüfen wir, ob ein Operator (=, -eq, etc.) folgt
      if let nextToken = tokens.first, case .op(let opStr) = nextToken,
         ["=", "!=", "-eq", "-ne", "-gt", "-lt"].contains(opStr) {
        
        _ = consume() // Operator konsumieren
        guard let rightToken = consume() else {
          log("Error: Missing right side of comparison")
          throw ParseError.invalidComparison
        }
        let rightVal = getStringValue(from: rightToken)
        
        log("Comparing: \(leftVal) \(opStr) \(rightVal)")
        
        switch opStr {
        case "=":   return leftVal == rightVal
        case "!=":  return leftVal != rightVal
        case "-gt": return (Int(leftVal) ?? 0) > (Int(rightVal) ?? 0)
        case "-lt": return (Int(leftVal) ?? 0) < (Int(rightVal) ?? 0)
        case "-eq": return (Int(leftVal) ?? 0) == (Int(rightVal) ?? 0)
        default: return false
        }
      }
      
      // 4. Fallback: Nur ein einzelner String
      log("Fallback String check: \(leftVal)")
      return !leftVal.isEmpty
    }
    
    func getStringValue(from token: Token) -> String {
      switch token {
      case .string(let s): return s
      case .number(let n): return String(n)
      case .op(let o): return o
      default: return ""
      }
    }
    
    func performSystemCheck(flag: String, path: String) -> Bool {
      var stats = stat()
      let exists = stat(path, &stats) == 0
      switch flag {
      case "-f": return exists && (stats.st_mode & S_IFMT == S_IFREG)
      case "-d": return exists && (stats.st_mode & S_IFMT == S_IFDIR)
      case "-u": return exists && (stats.st_mode & S_ISUID != 0)
      case "-g": return exists && (stats.st_mode & S_ISGID != 0)
      case "-t": return isatty(Int32(path) ?? 1) == 1
      case "-z": return path.isEmpty
      case "-n": return !path.isEmpty
      default: return false
      }
    }
  }
}
