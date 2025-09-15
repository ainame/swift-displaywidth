# swift-displaywidth

[![Swift Version](https://img.shields.io/badge/Swift-6.1%2B-blue.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ainame/swift-displaywidth/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/ainame/swift-displaywidth)](https://github.com/ainame/swift-displaywidth/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/ainame/swift-displaywidth/ci.yml?branch=main)](https://github.com/ainame/swift-displaywidth/actions)

A portable/cross-platform implementation of `wcwidth(3)` with up-to-date Unicode spec.
This project has own Unicode data tables generated from following files.

* https://unicode.org/Public/17.0.0/ucd/UnicodeData.txt
* https://unicode.org/Public/17.0.0/ucd/EastAsianWidth.txt

## Why use this?

Instead of this library, there's `wcwidth` imported with `import Darwin`, `import Musl`, or `import Glibc`.

- https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/wcwidth.3.html
- https://www.gnu.org/software/gnulib/manual/html_node/wcwidth.html
- https://git.musl-libc.org/cgit/musl/tree/src/ctype/wcwidth.c

If that meets your requirements, you should just use it. However, this project has following superior points.

- Portable/Cross-platform implementation that doesn't require a C library nor even Foundation
- Up-to-date Unicode spec
- Better support of Unicode grapheme clusters
- Swift-friendly API

## Usage

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ainame/swift-displaywidth", from: "0.0.3")
]
```

Then:

```swift
import DisplayWidth

// call as function
let displayWidth = DisplayWidth()
displayWidth("A")        // 1
displayWidth("あ")       // 2
displayWidth("👩‍💻")       // 2
displayWidth("e\u{0301}") // 1 (e + combining acute)

// If your environment treat ambiguous chars as full-width,
// you can set this option.
let displayWidth = DisplayWidth(treatAmbiguousAsFullWidth: true)
```

## Links

* https://man7.org/linux/man-pages/man3/wcwidth.3.html
* Other langs
   * Python https://github.com/jquast/wcwidth
   * Go https://github.com/mattn/go-runewidth/
   * JS https://github.com/komagata/eastasianwidth/
* https://emonkak.pages.dev/articles/wcwidth/
   * This project (to avoid using `wcwidth(3)`) is against to this blog post but I took ideas around full-width symbols
