// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core
import Foundation
import ArgumentParser

/// The is the envelope for MD5 algrithm. It takes the parameter, controls the workflow and print the results, but do not calculate the md5
@main
struct md5 : AsyncParsableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "md5",
      abstract: "calculate md5 hash",
      discussion:
      """
      """,
      version: "1.0.0"
    )
  }
  
  @Flag(name: [.short, .long], help: "Echo stdin to stdout and append the checksum to stdout. In this mode, any files specified onthe command line are silently ignored.")
  var passthrough = false
  
  @Flag(name: [.short, .long], help: "Quiet mode - only the checksum is printed. Overrides the -r or --reverse option.")
  var quiet = false
  
  @Flag(name: [.short, .customLong("reverse")], help: "Reverses the format of the output. This helps with visual diffs. Does nothing when combined with the -ptx options.")
  var reverse = false
  
  @Option(
    name: [.short, .customLong("string")],
    help: "Print a checksum of the given string. In this mode, any files specified on the command line are silently ignored."
  )
  var string: String?
  
  @Flag(name: [.customShort("x"), .customLong("self-test")], help: "Run a built-in test script.")
  var runBuiltInTest = false
  
  @Flag(name: [.customShort("t"), .customLong("time-trial")], help: "Run a built-in benchmark.")
  var runBuiltInBenchmark = false
  
  @Argument(help: "Files to hash.")
  var files: [String] = []
  
  static var bsd : Bool {
    !CommandLine.arguments[0].reversed().starts(with: "mus")
  }
  
  func run() async throws {
    // TODO: GNU - md5sum not supported yet - take a look to uutils if you need GNU reimplemention now
    guard md5.bsd else {
      Foundation.exit(255)
    }
    
    // benchmark
    if runBuiltInBenchmark {
      print ("MD5 time trial. Digesting 100000 10000-byte blocks ... ", terminator: "")
      let md5 = MD5()
      var digest : String = ""
      let clock = ContinuousClock()
      let randomBytes = Data((0..<10_000).map { _ in UInt8.random(in: 0...255) })

      let duration = clock.measure {
        for _ in 0..<100_000 {
          md5.update(with: randomBytes)
        }
        digest = md5.finalize()
      }
      let totalBytes = Double(100_000 * 10_000)
      let totalSeconds = Double(duration.components.seconds) + (Double(duration.components.attoseconds) / 1e18)
      let mibPerSecond = totalBytes / totalSeconds / (1024 * 1024)
      let time = String(format: "%.6f",totalSeconds)
      let speed = String(format: "%6f", mibPerSecond)

      print ("""
        done
        Digist = \(digest)
        Time = \(time) seconds
        Speed = \(speed) MiB/second
        """)
    }

    // Testsuite is
    if runBuiltInTest {
      runTestSuite()
      Foundation.exit(0)
    }
    if passthrough {
      let hasher = MD5()
      let stdin = FileHandle.standardInput
      let stdout = FileHandle.standardOutput
      
      while true {
        // Ein Puffer von 64 KB ist ideal für moderne CPUs
        let data = stdin.readData(ofLength: 65536)
        if data.isEmpty { break }
        
        // Echo
        stdout.write(data)
        
        // Inkrementelles Hashing
        hasher.update(with: data)
      }
      
      print(hasher.finalize())
      return
    }

    if let string {
      let hasher = MD5()
      if let data = string.data(using: .utf8) {
        hasher.update(with: data)
      }
      let hashD = hasher.finalize()
      printOutput(hash: hashD, source: string, isString: true)
    }
    else {
      // 2. Dateien verarbeiten (alles was nach den Flags kommt)
      for filename in files {
        do {
          let fileURL = URL(fileURLWithPath: filename)
          let handle = try FileHandle(forReadingFrom: fileURL)
          
          // 1. Hasher instanziieren
          let hasher = MD5()
          
          // 2. Blockweise lesen (z.B. 64 KB pro Durchgang)
          while let chunk = try handle.read(upToCount: 65536), !chunk.isEmpty {
            hasher.update(with: chunk)
          }
          
          try handle.close()
          
          // 3. Ergebnis abrufen
          let hash = hasher.finalize()
          printOutput(hash: hash, source: filename, isString: false)
        }
        catch {
          if !FileManager.default.fileExists(atPath: filename) {
            print("md5: \(filename): No such file or directory")
          }
          else {
            print("md5: \(filename): Permission denied")
          }
        }
      }
    }
  }
  
  func printOutput(hash: String, source: String, isString: Bool) {
    if md5.bsd {
      switch (quiet, reverse, isString) {
      case (true, _, _): // quiet
        print(hash)
      case (_, _, true): // -s
        print (hash)
      case (_,true, _):
        if string == nil {
          print (hash)
        }
        else {
          print("MD5 (\(source)) = \(hash)")
        }
      case (_,_, false):
        print("MD5 (\(source)) = \(hash)")
      default:
        print("MD5 (\(source)) = \(hash)")
      }
    }
    else {
      switch (md5.bsd) { // dummy for later GNU implementation
      case (false) :
        if nil != string {
          print("\(hash)  -")
        }
      default:
        break
      }
    }
  }
  
  func runTestSuite () {
    let testcases : [(content : String, expected : String)] = [
      ("", "d41d8cd98f00b204e9800998ecf8427e"),
      ("a", "0cc175b9c0f1b6a831c399e269772661"),
      ("abc", "900150983cd24fb0d6963f7d28e17f72"),
      ("message digest", "f96b697d7cb7938d525a2f31aaf161d0"),
      ("abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b"),
      ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "d174ab98d277d9f5a5611c2c9f419d9f"),
      ("12345678901234567890123456789012345678901234567890123456789012345678901234567890" , "57edf4a22be3c955ac49da2e2107b67a"),
      ("MD5 has not yet (2001-09-03) been broken, but sufficient attacks have been made that its security is in some doubt", "b50663f41d44d92171cb9976bc118538")
    ]
    print ("MD5 test suite:")
    // speed is not important
    for test in testcases {
      let hasher = MD5()
      if let data = test.content.data(using: .utf8) {
        hasher.update(with: data)
      }
      let md5 = hasher.finalize()
      
      let verified = md5 == test.expected
      print ("MD5 (\(test.content)) = \(md5) - verified \( verified ? "correct" : "failure")") // maybe failure, but never see
      
      // if not verified it is better to stop then print more false results
      if !verified {
        fatalError("MD5 algorithm implementation error")
      }
    }
  }
}
