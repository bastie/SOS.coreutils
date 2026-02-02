// SPDX-License-Identifier: EUPL-1.2 OR Apache-2.0 OR 0BSD
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public struct _wc {
  public init(){}
  
  public func processFile(at path: String) throws(WCError) -> WCResult {
    guard let data = FileManager.default.contents(atPath: path) else {
      throw .fileNotFound(path)
    }
    
    guard let content = String(data: data, encoding: .utf8) else {
      throw .unreadableEncoding(path)
    }
    
    var result = analyze(content, filename: path)
    
    // Für die Bytezählung naiv über die eingelesenen Daten
    result.bytes = data.count
    
    return result
  }
  
  func analyze(_ content: String, filename: String? = nil) -> WCResult {
    // Naive Zeilenzählung über Zerlegung nach Zeilenumbrüche (U+000A ~ U+000D, U+0085, U+2028, and U+2029).
    let lines = content.components(separatedBy: .newlines)
    let lineCount = lines.count - 1
    
    var lengthOfLengthestLine = 0
    for line in lines {
      if line.count > lengthOfLengthestLine {
        lengthOfLengthestLine = line.count
      }
    }
    
    // Naive Wortzählung über Whitespaces
    let words = content.split { $0.isWhitespace }.count
    
    // Naive Characterzählung
    let chars = content.count
    
    return WCResult(lines: max(0, lineCount), words: words, maxlinelength: lengthOfLengthestLine, charachters: chars, filename: filename)
  }

}
public struct WCResult {
  public let lines: Int
  public let words: Int
  public var bytes: Int = 0
  public let maxlinelength : Int
  public let charachters : Int
  public let filename: String?
}
public enum WCError: Error {
  case fileNotFound(String)
  case unreadableEncoding(String)
}
