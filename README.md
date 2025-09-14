# swift-displaywidth

[![Swift Version](https://img.shields.io/badge/Swift-6.1%2B-blue.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ainame/swift-displaywidth/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/ainame/swift-displaywidth)](https://github.com/ainame/swift-displaywidth/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/ainame/swift-displaywidth/ci.yml?branch=main)](https://github.com/ainame/swift-displaywidth/actions)

Small, testable display width implementation in Swift. Provides simple functions to measure display width of Unicode scalars, characters, and strings with an option to treat East Asian "Ambiguous" width as full-width.

## Usage

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ainame/swift-displaywidth", from: "0.0.2")
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

* Naming reference https://man7.org/linux/man-pages/man3/wcwidth.3.html
* Other langs
   * Python https://github.com/jquast/wcwidth
   * Go https://github.com/mattn/go-runewidth/
   * JS https://github.com/komagata/eastasianwidth/
