// swift-tools-version: 6.2
// SPDX-License-Identifier: EUPL-1.2 OR Apache-2.0 OR 0BSD
// SPDX-FileCopyrightText: © 2026 Sebastian Ritter

import PackageDescription

let package = Package(
  name: "coreutils",
  platforms: [.macOS(.v26),.custom("FreeBSD", versionString: "14.3")],
  products: [
    .executable(name: "head", targets: ["head"]),
    .executable(name: "sleep", targets: ["sleep"]),
    .executable(name: "wc", targets: ["wc"]),
    
    .executable(name: "garoto", targets: ["garoto"]),
  ],
  dependencies: [
    .package(url: "https://github.com/bastie/SOS.libutil", from: "0.1.0"), //.package(path: "../SOS.libutil"),
    .package(url: "https://github.com/bastie/SOS.libc", from: "0.1.0"),//.package(path: "../SOS.libc"),
  ],
  targets: [
    // MARK: core target as library, so we can test it
    .target(name: "core"),
    
    // MARK: head target use some provided library functions of libc and libutil
    .executableTarget(
      name: "head",
      dependencies: [
        "core",
        .product(name: "util", package: "SOS.libutil"),
        .product(name: "c", package: "SOS.libc")
      ]
    ),
    
    // MARK: wc target use some provided library function of libc
    .executableTarget(
      name: "sleep" ,
      dependencies: [
        "core",
        .product(name: "c", package: "SOS.libc")
      ]
    ),

    // MARK: wc target use some provided library function of libc
    .executableTarget(
      name: "wc" ,
      dependencies: [
        "core",
        .product(name: "c", package: "SOS.libc")
      ]
    ),
    
    // MARK: ☕️
    .executableTarget(name: "garoto" , dependencies: ["core"]),
  
    .testTarget(name: "coreutilsTests"),
  ]
)

