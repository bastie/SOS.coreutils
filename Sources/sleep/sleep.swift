// SPDX-License-Identifier: EUPL-1.2 OR Apache-2.0 OR 0BSD
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import Foundation
import core

/// ```sleep``` do nothing for given second number value
/// - Version: 1.0.0 OpenBSD / NetBSD like implementation without extensions of FreeBSD or Linux or macOS
/// - Authors:
///   - Sebastian Ritter
@main
public struct sleep {
  
  public static func main () async throws {
    guard CommandLine.arguments.count > 1 else {
      exit(1)
    }

    if var nanoseconds = UInt64(CommandLine.arguments[1]) {
      /// with time alignment we correct a little bit the time between
      /// the call of executable to the really sleep
      /// this **time alignment** depends on implementation statements before
      let timeAlignment : UInt64 = 59_000_000
      nanoseconds *= 1_000_000_000 - timeAlignment
      await _sleep.sleep(nanoseconds: nanoseconds)
      
      exit (0)
    }
    else {
      exit (1)
    }
  }
}
