// SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

public struct _sleep {

  @inlinable
  public static func sleep (nanoseconds value : UInt64) async {
    do {
      let _ = try await Task.sleep(nanoseconds: value)
    }
    catch {}
  }
}
