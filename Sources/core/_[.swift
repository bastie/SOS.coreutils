// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation
import Darwin

public struct `_[` {
  
  /*
   import Foundation
   import Darwin
   
   // --- 1. DATENSTRUKTUREN ---
   enum Token: Equatable {
   case number(Int), string(String), op(String)
   case openParen, closeParen, logicalAnd, logicalOr
   }
   
   enum ParseError: Error {
   case unexpectedToken(Token?), missingClosingParenthesis, invalidComparison
   }
   
   // --- 2. DER LEXER ---
   struct Lexer {
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
   
   func tokenize(_ args: [String]) -> [Token] {
   return args.map { arg in
   let s = resolve(arg)
   switch s {
   case "(": return .openParen
   case ")": return .closeParen
   case "-a": return .logicalAnd
   case "-o": return .logicalOr
   case "!":  return .op("!")
   case let x where x.hasPrefix("-") && x.count > 1: return .op(x)
   case let x where Int(x) != nil: return .number(Int(x)!)
   default: return .string(s)
   }
   }
   }
   }
   
   // --- 3. DER PARSER MIT DEBUG-VISUALISIERER ---
   class Parser {
   var tokens: [Token]
   var depth = 0
   var debugMode = false
   
   init(tokens: [Token], debug: Bool = false) {
   self.tokens = tokens
   self.debugMode = debug
   }
   
   private func log(_ message: String) {
   if debugMode {
   let prefix = String(repeating: "  │ ", count: depth)
   print("\(prefix)── \(message)")
   }
   }
   
   func consume() -> Token? { tokens.isEmpty ? nil : tokens.removeFirst() }
   
   func parseOR() throws -> Bool {
   log("Checking OR-Level (-o)")
   depth += 1; defer { depth -= 1 }
   var left = try parseAND()
   while tokens.first == .logicalOr {
   _ = consume()
   let right = try parseAND()
   left = left || right
   }
   return left
   }
   
   func parseAND() throws -> Bool {
   log("Checking AND-Level (-a)")
   depth += 1; defer { depth -= 1 }
   var left = try parseUnary()
   while tokens.first == .logicalAnd {
   _ = consume()
   let right = try parseUnary()
   left = left && right
   }
   return left
   }
   
   func parseUnary() throws -> Bool {
   if tokens.first == .op("!") {
   log("NOT found (!)")
   _ = consume()
   depth += 1; defer { depth -= 1 }
   return try !parseUnary()
   }
   return try parsePrimary()
   }
   
   /*
    func parsePrimary() throws -> Bool {
    guard let token = consume() else { throw ParseError.unexpectedToken(nil) }
    log("Evaluating: \(token)")
    
    if token == .openParen {
    depth += 1
    let res = try parseOR()
    depth -= 1
    guard consume() == .closeParen else { throw ParseError.missingClosingParenthesis }
    return res
    }
    
    // System-Tests (Unär: -f, -d, -u, -g, -t)
    if case .op(let flag) = token {
    guard let next = consume() else { throw ParseError.invalidComparison }
    
    // Wir extrahieren den String-Inhalt des Tokens sicher
    let path: String
    if case .string(let s) = next {
    path = s
    } else if case .number(let n) = next {
    path = String(n)
    } else {
    path = "" // Oder ein Fallback
    }
    
    return performSystemCheck(flag: flag, path: path)
    }
    
    // Vergleiche (Binär: 10 -gt 5)
    if case .number(let left) = token {
    guard let opToken = consume(), case .op(let op) = opToken,
    let next = consume(), case .number(let right) = next else {
    throw ParseError.invalidComparison
    }
    switch op {
    case "-gt": return left > right
    case "-lt": return left < right
    case "-eq": return left == right
    default: return false
    }
    }
    return false
    }
    */
   
   /*
    func parsePrimary() throws -> Bool {
    guard let token = consume() else { throw ParseError.unexpectedToken(nil) }
    log("Evaluating: \(token)")
    
    if token == .openParen {
    let res = try parseOR()
    guard consume() == .closeParen else { throw ParseError.missingClosingParenthesis }
    return res
    }
    
    // FALL 1: Unärer Operator (z.B. -u <Pfad> oder -f <Pfad>)
    if case .op(let flag) = token {
    guard let next = consume() else { throw ParseError.invalidComparison }
    let path = getStringValue(from: next)
    return performSystemCheck(flag: flag, path: path)
    }
    
    // FALL 2: Binärer Vergleich (z.B. admin = admin oder 10 -gt 5)
    // Wir schauen uns das NÄCHSTE Token an, ohne es zu löschen (Peek)
    if let nextToken = tokens.first {
    if case .op(let op) = nextToken {
    _ = consume() // Den Operator (z.B. "=" oder "-gt") konsumieren
    guard let rightToken = consume() else { throw ParseError.invalidComparison }
    
    let leftStr = getStringValue(from: token)
    let rightStr = getStringValue(from: rightToken)
    
    switch op {
    case "=":   return leftStr == rightStr
    case "!=":  return leftStr != rightStr
    case "-gt": return (Int(leftStr) ?? 0) > (Int(rightStr) ?? 0)
    case "-lt": return (Int(leftStr) ?? 0) < (Int(rightStr) ?? 0)
    case "-eq": return (Int(leftStr) ?? 0) == (Int(rightStr) ?? 0)
    default: return false
    }
    }
    }
    
    // Fallback: Einfacher String-Check (ist nicht leer?)
    return !getStringValue(from: token).isEmpty
    }
    */
   
   // Hilfsfunktion zur String-Extraktion
   func getStringValue(from token: Token) -> String {
   switch token {
   case .string(let s): return s
   case .number(let n): return String(n)
   case .op(let o):     return o
   default:             return ""
   }
   }
   /*
    func parsePrimary() throws -> Bool {
    // 1. Sicherheitscheck: Haben wir überhaupt noch Tokens?
    guard let firstToken = tokens.first else {
    throw ParseError.unexpectedToken(nil)
    }
    
    log("Primary Level - Current Token: \(firstToken)")
    
    // 2. FALL: Klammerung ( )
    if firstToken == .openParen {
    _ = consume() // '(' wegwerfen
    let res = try parseOR() // Rekursion für den Inhalt
    if consume() != .closeParen {
    throw ParseError.missingClosingParenthesis
    }
    return res
    }
    
    // 3. FALL: Unärer Operator (z.B. -f, -u, -d, -t, -z)
    if case .op(let flag) = firstToken, ["-f", "-d", "-u", "-g", "-t", "-z"].contains(flag) {
    _ = consume() // Flag konsumieren
    guard let next = consume() else { throw ParseError.invalidComparison }
    let path = getStringValue(from: next)
    return performSystemCheck(flag: flag, path: path)
    }
    
    // 4. FALL: Binärer Vergleich (z.B. A = B oder 1 -gt 2)
    // Wir nehmen das erste Token (links)
    let leftToken = consume()!
    let leftVal = getStringValue(from: leftToken)
    
    // Schauen, ob danach ein Vergleichs-Operator kommt
    if let opToken = tokens.first, case .op(let opStr) = opToken,
    ["=", "!=", "-eq", "-ne", "-gt", "-lt", "-ge", "-le"].contains(opStr) {
    
    _ = consume() // Operator konsumieren
    guard let rightToken = consume() else { throw ParseError.invalidComparison }
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
    
    // 5. FALLBACK: Einfacher String-Test (Wahr, wenn nicht leer)
    return !leftVal.isEmpty
    }
    */
   func parsePrimary() throws -> Bool {
   guard let firstToken = tokens.first else {
   throw ParseError.unexpectedToken(nil)
   }
   
   log("Primary Level - Current Token: \(firstToken)")
   
   // 1. Klammerung
   if firstToken == .openParen {
   _ = consume()
   let res = try parseOR()
   guard let next = consume(), next == .closeParen else {
   throw ParseError.missingClosingParenthesis
   }
   log("Closed Parenthesis")
   return res
   }
   
   // 2. Unärer Operator (-f, -u, etc.)
   if case .op(let flag) = firstToken, ["-f", "-d", "-u", "-g", "-t", "-z"].contains(flag) {
   _ = consume()
   guard let next = consume() else { throw ParseError.invalidComparison }
   return performSystemCheck(flag: flag, path: getStringValue(from: next))
   }
   
   // 3. Binärer Vergleich oder Einzelstring
   let leftToken = consume()!
   let leftVal = getStringValue(from: leftToken)
   
   // WICHTIG: Schau nach dem Operator (=, -eq, etc.)
   if let nextToken = tokens.first, case .op(let opStr) = nextToken,
   ["=", "!=", "-eq", "-ne", "-gt", "-lt", "-ge", "-le"].contains(opStr) {
   
   _ = consume() // Operator weg
   guard let rightToken = consume() else { throw ParseError.invalidComparison }
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
   
   // Fallback: [ "string" ] ist wahr, wenn nicht leer
   return !leftVal.isEmpty
   }
   
   func performSystemCheck(flag: String, path: String) -> Bool {
   var stats = stat()
   let exists = stat(path, &stats) == 0
   let mode = stats.st_mode
   switch flag {
   case "-f": return exists && (mode & S_IFMT == S_IFREG)
   case "-d": return exists && (mode & S_IFMT == S_IFDIR)
   case "-u": return exists && (mode & S_ISUID != 0)
   case "-g": return exists && (mode & S_ISGID != 0)
   case "-t": return isatty(Int32(path) ?? 1) == 1
   case "-z": return path.isEmpty
   default: return false
   }
   }
   }
   
   @main
   struct `[` {
   public static func main (){
   // --- 4. MAIN ENTRY POINT ---
   var args = Array(CommandLine.arguments.dropFirst())
   var debug = false
   
   if args.contains("--tree") {
   debug = true
   args.removeAll(where: { $0 == "--tree" })
   }
   
   let cleanArgs = args.last == "]" ? Array(args.dropLast()) : args
   let tokens = Lexer().tokenize(cleanArgs)
   let parser = Parser(tokens: tokens, debug: debug)
   
   do {
   let result = try parser.parseOR()
   if debug { print("── Result: \(result)") }
   exit(result ? 0 : 1)
   } catch {
   fputs("Syntax Error\n", stderr)
   exit(2)
   }
   }
   }
   */
  
  // --- 1. TOKENS ---
  public enum Token: Equatable {
    case number(Int), string(String), op(String)
    case openParen, closeParen, logicalAnd, logicalOr
  }
  
  enum ParseError: Error {
    case unexpectedToken(Token?), missingClosingParenthesis, invalidComparison
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
    
    /*
     func tokenize(_ args: [String]) -> [Token] {
     return args.map { arg in
     let s = resolve(arg)
     switch s {
     case "(": return .openParen
     case ")": return .closeParen
     case "-a": return .logicalAnd
     case "-o": return .logicalOr
     case "!":  return .op("!")
     case let x where x.hasPrefix("-") && x.count > 1: return .op(x)
     case let x where Int(x) != nil: return .number(Int(x)!)
     default: return .string(s)
     }
     }
     }
     */
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
    
    /*
     func parseOR() throws -> Bool {
     log("OR-Level")
     depth += 1; defer { depth -= 1 }
     var left = try parseAND()
     while tokens.first == .logicalOr {
     _ = consume()
     let right = try parseAND()
     left = left || right
     }
     return left
     }
     
     func parseAND() throws -> Bool {
     log("AND-Level")
     depth += 1; defer { depth -= 1 }
     var left = try parseUnary()
     while tokens.first == .logicalAnd {
     _ = consume()
     let right = try parseUnary()
     left = left && right
     }
     return left
     }
     */
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
    
    /*
     func parseAND() throws -> Bool {
     log("AND-Level Start")
     var left = try parseUnary()
     
     while tokens.first == .logicalAnd {
     _ = consume() // -a entfernen
     log("AND Operator found")
     let right = try parseUnary()
     left = left && right
     }
     return left
     }
     */
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
    /*
     func parsePrimary() throws -> Bool {
     guard let firstToken = tokens.first else { throw ParseError.unexpectedToken(nil) }
     log("Primary: \(firstToken)")
     
     // A. Klammern
     if firstToken == .openParen {
     _ = consume()
     let res = try parseOR()
     guard consume() == .closeParen else { throw ParseError.missingClosingParenthesis }
     return res
     }
     
     /*
      // B. Unäre Tests (-f, -u, etc.)
      let unaryFlags = ["-f", "-d", "-u", "-g", "-t", "-z", "-n"]
      if case .op(let flag) = firstToken, unaryFlags.contains(flag) {
      _ = consume()
      guard let next = consume() else { throw ParseError.invalidComparison }
      return performSystemCheck(flag: flag, path: getStringValue(from: next))
      }
      */
     // B. Unäre Tests (-f, -d, -u, -g, -t, -z, -n)
     let unaryFlags = ["-f", "-d", "-u", "-g", "-t", "-z", "-n"]
     if case .op(let flag) = firstToken, unaryFlags.contains(flag) {
     _ = consume() // Flag (-u) entfernen
     guard let pathToken = consume() else { throw ParseError.invalidComparison }
     let path = getStringValue(from: pathToken)
     
     log("SystemCheck: \(flag) on \(path)") // DEBUG INFO
     
     let result = performSystemCheck(flag: flag, path: path)
     return result
     }
     
     // C. Binäre Vergleiche
     let leftToken = consume()!
     if let nextToken = tokens.first, case .op(let opStr) = nextToken,
     ["=", "!=", "-eq", "-ne", "-gt", "-lt"].contains(opStr) {
     _ = consume()
     guard let rightToken = consume() else { throw ParseError.invalidComparison }
     
     let l = getStringValue(from: leftToken)
     let r = getStringValue(from: rightToken)
     log("Compare: \(l) \(opStr) \(r)")
     
     switch opStr {
     case "=": return l == r
     case "!=": return l != r
     case "-gt": return (Int(l) ?? 0) > (Int(r) ?? 0)
     case "-lt": return (Int(l) ?? 0) < (Int(r) ?? 0)
     case "-eq": return (Int(l) ?? 0) == (Int(r) ?? 0)
     default: return false
     }
     }
     
     // D. Fallback
     return !getStringValue(from: leftToken).isEmpty
     }
     */
    /*
     func parsePrimary() throws -> Bool {
     guard let firstToken = tokens.first else { throw ParseError.unexpectedToken(nil) }
     log("Primary: \(firstToken)")
     
     // 1. Klammerung
     if firstToken == .openParen {
     _ = consume()
     let res = try parseOR()
     guard consume() == .closeParen else { throw ParseError.missingClosingParenthesis }
     return res
     }
     
     // 2. Unäre Tests
     /*
      let unaryFlags = ["-f", "-d", "-u", "-g", "-t", "-z", "-n"]
      if case .op(let flag) = firstToken, unaryFlags.contains(flag) {
      _ = consume()
      guard let pathToken = consume() else { throw ParseError.invalidComparison }
      return performSystemCheck(flag: flag, path: getStringValue(from: pathToken))
      }
      */
     if case .op(let flag) = firstToken, ["-f", "-d", "-u", "-g", "-t", "-z", "-n"].contains(flag) {
     _ = consume() // Entferne das Flag (z.B. -u)
     
     // WICHTIG: Das NÄCHSTE Token MUSS der Pfad sein
     guard let pathToken = consume() else {
     log("ERROR: No path after \(flag)")
     throw ParseError.invalidComparison
     }
     
     let path = getStringValue(from: pathToken)
     log("SystemCheck: \(flag) on \(path)")
     return performSystemCheck(flag: flag, path: path)
     }
     
     // 3. Binärer Vergleich (MUSS vor dem Fallback kommen!)
     let leftToken = consume()! // Das erste Wort nehmen (z.B. "bastie")
     if let opToken = tokens.first, case .op(let opStr) = opToken,
     ["=", "!=", "-eq", "-ne", "-gt", "-lt"].contains(opStr) {
     
     _ = consume() // Operator (=) weg
     guard let rightToken = consume() else { throw ParseError.invalidComparison }
     
     let l = getStringValue(from: leftToken)
     let r = getStringValue(from: rightToken)
     log("Comparing: \(l) \(opStr) \(r)")
     
     switch opStr {
     case "=": return l == r
     case "!=": return l != r
     case "-gt": return (Int(l) ?? 0) > (Int(r) ?? 0)
     case "-lt": return (Int(l) ?? 0) < (Int(r) ?? 0)
     case "-eq": return (Int(l) ?? 0) == (Int(r) ?? 0)
     default: return false
     }
     }
     
     // 4. Fallback (Nur wenn kein Operator folgte)
     return !getStringValue(from: leftToken).isEmpty
     }
     */
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
      /*    if firstToken == .openParen {
       _ = consume()
       let res = try parseOR()
       guard consume() == .closeParen else { throw ParseError.missingClosingParenthesis }
       return res
       }
       */
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
