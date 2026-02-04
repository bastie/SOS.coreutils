// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import core

@main
public struct whoami {
  
  public static func main () async {
    print (_whoami().whoami)
  }
}
