# Repository Guidelines

## Project Overview

A portable/cross-platform Swift implementation of `wcwidth(3)` that calculates display width of Unicode characters and strings. Uses up-to-date Unicode 17.0.0 spec with better grapheme cluster support than system `wcwidth`. No dependencies on C libraries or Foundation (except for locale-aware variant).

**Swift Version**: 6.2 (see `.swift-version`)

**Platforms**: macOS 12+, iOS 15+, tvOS 15+, watchOS 8+

## Project Structure & Module Organization

- `Package.swift` — SwiftPM manifest (Swift 6.1 tools-version).
- `Sources/DisplayWidth/` — library source (public API and width logic).
- `Sources/Generate/` — executable that fetches Unicode data and writes `Sources/DisplayWidth/UnicodeData.generated.swift`.
- `Tests/DisplayWidthTests/` — tests using the Swift `Testing` library (`@Test`).
- `.swiftpm/`, `.build/` — toolchain and build artifacts (do not commit generated artifacts).

## Architecture

### Core Components

**Main Public API** (`DisplayWidth.swift`):
- Callable struct with `callAsFunction` for String/Character/UnicodeScalar
- Configuration: `treatAmbiguousAsFullWidth` (default: false)
- Single-scalar fast path, complex grapheme cluster handling for emojis/combining marks

**Width Calculation Flow**:
1. Control characters (null, DEL) → width 0
2. Unicode General Category lookup (marks, ZWJ, variation selectors) → width 0
3. East Asian Width attribute lookup → Fullwidth/Wide = 2, others = 1
4. Special-cased wide symbols (emojis/symbols marked neutral but should be width 2)
5. Grapheme cluster aggregation for multi-scalar sequences

**Unicode Data Lookup** (`UnicodeData.swift` + `UnicodeData.generated.swift`):
- Binary search on sorted Unicode range arrays
- Two property lookups: GeneralCategory (30 types) and EastAsianWidthAttribute (6 types)
- Auto-generated from unicode.org data files via `Generate` executable

**Binary Search** (`BinarySearch.swift`):
- Performance-optimized range search for Unicode property tables

**Locale-Aware Variant** (`LocaleAwareDisplayWidth.swift`):
- Foundation-dependent wrapper
- Auto-detects East Asian locales (ja, ko, zh) and sets `treatAmbiguousAsFullWidth: true`

## Build, Test, and Development Commands

- `swift build` — compile library and executables.
- `swift test` — run the test suite.
- `swift test --enable-code-coverage` — run tests with coverage.
- `swift run generate` — regenerate Unicode tables from unicode.org and update `UnicodeData.generated.swift` (requires network). Commit the regenerated file when behavior changes.
- `swift package update` — refresh dependencies if needed.

## Coding Style & Naming Conventions

- Follow Swift API Design Guidelines; 2‑space indentation; trim trailing whitespace.
- Types and enums: UpperCamelCase. Methods, vars, cases: lowerCamelCase. Files named after the primary type.
- Prefer small, testable units and pure functions for width calculations; keep I/O and generation code in `Generate`.
- Public API must have doc comments. Avoid introducing new dependencies.

## Testing Guidelines

**Framework**: Swift `Testing` module. Add `@Test` functions with clear, behavior‑focused names.

**Coverage Areas**:
- ASCII and control characters
- Ambiguous characters (context-dependent width)
- Complex grapheme clusters (combining marks, ZWJ sequences, flags, skin tones)
- Emoji support (individual, compound, variation selectors)
- Wide symbols (miscellaneous symbols, dingbats, mahjong, playing cards)
- Locale-aware behavior (East Asian language detection)
- Edge cases (empty strings, mixed-width content)

Run with `swift test`; for coverage locally use `swift test --enable-code-coverage`.

## Commit & Pull Request Guidelines

- Commits: imperative mood, concise subject, contextual body when needed (e.g., `fix: correct width for U+0300 combining marks`). Make logical, small commits.
- Tags: use semantic version tags without the `v` prefix (e.g., `1.2.0`).
- PRs: include a summary, motivation, before/after behavior, tests, and notes on whether `UnicodeData.generated.swift` was regenerated.

## Agent‑Specific Instructions

- Do not use `swift-actions/setup-swift@v2` in CI. Use toolchains available on runners or an alternative setup.
- Validate changes with `swift build` or `swift test` before opening PRs.
- When exploring the codebase programmatically, prefer the Serena MCP server; for large cross‑file analysis, use the Gemini CLI (e.g., `gemini -p "@Sources/ Summarize modules"`).
