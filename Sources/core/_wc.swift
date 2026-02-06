// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation

public struct _wc {
  public init(){}
  
  public func processFile(with params : _WCParameter) async throws(_WCError) -> _WCResult {
    guard FileManager.default.fileExists(atPath: params.filename) else {
      throw .fileNotFound(params.filename)
    }
    
    let result = try await analyzeFile(params: params)
    
    return result
  }
  
  func analyzeFile(params : _WCParameter) async throws(_WCError) -> _WCResult {

    var data : Data?
    var result = _WCResult()
    
    if params.bytes {
      data = loadFile(path: params.filename)
      result.bytes = data!.count
    }
    
    var content : String?
    if params.characters {
      if nil == data {
        data = loadFile(path: params.filename)
      }
      
      guard let content = String(data: data!, encoding: .utf8) else {
        throw .unreadableEncoding(params.filename)
      }
      // Naive Characterzählung
      let chars = content.count
      result.characters = chars
    }
    var lines : [String]?
    if params.lines {
      #if canImport(Darwin)
      result.lines = await lineCount(for: params.filename)
      #else // platform neutral implementation in Swift
      if nil == data {
        data = loadFile(path: params.filename)
      }
      if nil == content {
        content = String(data: data!, encoding: .utf8)
        guard nil != content else {
          throw .unreadableEncoding(params.filename)
        }
      }
      // Naive Zeilenzählung über Zerlegung nach Zeilenumbrüche U+000A.
      lines = content!.components(separatedBy: CharacterSet(["\n"]))
      let lineCount = lines!.count - 1
      
      result.lines = lineCount
      #endif
    }
    if params.maxlinelength {
      if nil == data {
        data = loadFile(path: params.filename)
      }
      if nil == content {
        content = String(data: data!, encoding: .utf8)
        guard nil != content else {
          throw .unreadableEncoding(params.filename)
        }
      }
      if nil == lines {
        lines = content!.components(separatedBy: .newlines)
      }
      
      var lengthOfLongestLine = 0
      for line in lines! {
        if line.count > lengthOfLongestLine {
          lengthOfLongestLine = line.count
        }
      }
      
      result.maxlinelength = lengthOfLongestLine
    }
    if params.words {
      if nil == data {
        data = loadFile(path: params.filename)
      }
      if nil == content {
        content = String(data: data!, encoding: .utf8)
        guard nil != content else {
          throw .unreadableEncoding(params.filename)
        }
      }
      // Naive Wortzählung über Whitespaces
      let words = content!.split { $0.isWhitespace }.count
      result.words = words
    }

    return result
  }

  
  @inline(__always)
  func loadFile (path filename : String)  -> Data {
    return FileManager.default.contents(atPath: filename)!
  }
}



public struct _WCParameter {
  public init(lines: Bool, words: Bool, bytes: Bool, maxlinelength: Bool, characters: Bool, filename: String) {
    self.lines = lines
    self.words = words
    self.bytes = bytes
    self.maxlinelength = maxlinelength
    self.characters = characters
    self.filename = filename
  }
  public let lines: Bool
  public let words: Bool
  public var bytes: Bool
  public let maxlinelength : Bool
  public let characters : Bool
  public let filename: String
}

public struct _WCResult {
  public var lines: Int = 0
  public var words: Int = 0
  public var bytes: Int = 0
  public var maxlinelength : Int = 0
  public var characters : Int = 0
  public var filename: String? = nil
}
public enum _WCError: Error {
  case fileNotFound(String)
  case unreadableEncoding(String)
}
