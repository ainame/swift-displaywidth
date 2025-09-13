# swift-wcwidth

[![Swift Version](https://img.shields.io/badge/Swift-6.1%2B-blue.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ainame/swift-wcwidth/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/ainame/swift-wcwidth)](https://github.com/ainame/swift-wcwidth/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/ainame/swift-wcwidth/ci.yml?branch=main)](https://github.com/ainame/swift-wcwidth/actions)

Small, testable wcwidth implementation in Swift. Provides simple functions to measure display width of Unicode scalars, characters, and strings with an option to treat East Asian “Ambiguous” width as full-width.

## Usage

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ainame/swift-wcwidth", from: "0.1.0")
]
```

Then:

```swift
import Wcwidth

let wc = Wcwidth(treatAmbiguousAsFullWidth: false)
wc("A")        // 1
wc("中")        // 2
wc("👩‍💻")       // 2
wc("e\u{0301}") // 1 (e + combining acute)
```

