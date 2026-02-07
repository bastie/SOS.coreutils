// SPDX-License-Identifier: EUPL-1.2 OR Apache-2.0 OR 0BSD
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Testing
@testable import core // Name aus deiner Package.swift

@Suite("[ Tests")
struct ParserTests {
  
  @Test("Einfacher erfolgreicher String-Vergleich")
  func testComparisonTrue() async throws {
    let tokens: [_bracket.Token] = [.string("Sebastian Ritter"), .op("="), .string("Sebastian Ritter")]
    let parser = _bracket.Parser(tokens: tokens)
    
    let result = try parser.parseOR()
    
    #expect(result == true)
  }
  
  @Test("Einfacher fehlerhafter String-Vergleich")
  func testComparisonFalse() async throws {
    let tokens: [_bracket.Token] = [.string("Sebastian Ritter"), .op("="), .string("Bastie")]
    let parser = _bracket.Parser(tokens: tokens)
    
    let result = try parser.parseOR()
    
    #expect(result == false)
  }
  
  @Test("Logische Verknüpfung mit Klammern", arguments: [
    (["(", "1", "=", "1", "-a", "2", "=", "2", ")"], true),
    (["(", "1", "=", "2", "-o", "2", "=", "2", ")"], true),
    (["!", "(", "1", "=", "1", ")"], false)
  ])
  func testComplexLogic(args: [String], expected: Bool) throws {
    // Wir nutzen hier deinen Lexer, um echte Strings zu testen
    let lexer = _bracket.Lexer()
    let tokens = lexer.tokenize(args)
    let parser = _bracket.Parser(tokens: tokens)
    
    let result = try parser.parseOR()
    
    #expect(result == expected)
  }
  
  @Test("Syntax Fehler Erkennung")
  func testMissingBracket() {
    let tokens: [_bracket.Token] = [.openParen, .string("test")]
    let parser = _bracket.Parser(tokens: tokens)
    
    #expect {
      try parser.parseOR()
    } throws: { error in
      // Hier prüfen wir gezielt, ob es der richtige Case ist
      guard let parseError = error as? _bracket.ParseError else { return false }
      return parseError == .missingClosingParenthesis
    }
  }}
