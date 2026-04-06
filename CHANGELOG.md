# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-04-06

### Added

- Added `stripsANSI` so string measurement can ignore CSI, OSC, and APC/Kitty-style escape sequences without changing character or scalar width behavior. [#1](https://github.com/ainame/swift-displaywidth/pull/1)
- Added tab-aware string measurement for terminal-style tab stops and fixed-space tab expansion through `DisplayWidth.Tab`. [#3](https://github.com/ainame/swift-displaywidth/pull/3)
- Added regression coverage for embedded terminal image escapes and the tab mode behavior differences. [#1](https://github.com/ainame/swift-displaywidth/pull/1)

### Changed

- Replaced the older `tabWidth` configuration with the clearer `tab: DisplayWidth.Tab` API, including `.tabStops(n)` and `.fixedSpaces(n)`. [#3](https://github.com/ainame/swift-displaywidth/pull/3)
- Improved the README with ANSI-aware examples, tab mode diagrams, and guidance on how tab-stop and fixed-space counting differ. [#1](https://github.com/ainame/swift-displaywidth/pull/1)
- Reduced overhead in processed string measurement by scanning Unicode scalars in chunks and avoiding temporary array allocation for multi-scalar graphemes. [#2](https://github.com/ainame/swift-displaywidth/pull/2)

### Fixed

- Fixed follow-up issues in the ANSI and tab-aware measurement work while preserving the default behavior when the new options are left unset. [#1](https://github.com/ainame/swift-displaywidth/pull/1)
