// SPDX-License-Identifier: EUPL-1.2 OR Apache-2.0 OR 0BSD
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
