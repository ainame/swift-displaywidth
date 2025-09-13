# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` — SwiftPM manifest (Swift 6.1).
- `Sources/Wcwidth/` — library source (public API and width logic).
- `Sources/Generate/` — executable that fetches Unicode data and writes `Sources/Wcwidth/UnicodeData.generated.swift`.
- `Tests/WcwidthTests/` — tests using the Swift `Testing` library (`@Test`).
- `.swiftpm/`, `.build/` — toolchain and build artifacts (do not commit generated artifacts).

## Build, Test, and Development Commands
- `swift build` — compile library and executables.
- `swift test` — run the test suite.
- `swift run generate` — regenerate Unicode tables from unicode.org and update `UnicodeData.generated.swift` (requires network). Commit the regenerated file when behavior changes.
- `swift package update` — refresh dependencies if needed.

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines; 2‑space indentation; trim trailing whitespace.
- Types and enums: UpperCamelCase. Methods, vars, cases: lowerCamelCase. Files named after the primary type.
- Prefer small, testable units and pure functions for width calculations; keep I/O and generation code in `Generate`.
- Public API must have doc comments. Avoid introducing new dependencies.

## Testing Guidelines
- Framework: Swift `Testing` module. Add `@Test` functions with clear, behavior‑focused names.
- Cover ASCII, combining marks, ambiguous, and full‑width paths; add regression tests for edge cases.
- Run with `swift test`; for coverage locally use `swift test --enable-code-coverage`.

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise subject, contextual body when needed (e.g., `fix: correct width for U+0300 combining marks`). Make logical, small commits.
- Tags: use semantic version tags without the `v` prefix (e.g., `1.2.0`).
- PRs: include a summary, motivation, before/after behavior, tests, and notes on whether `UnicodeData.generated.swift` was regenerated.

## Agent‑Specific Instructions
- Do not use `swift-actions/setup-swift@v2` in CI. Use toolchains available on runners or an alternative setup.
- Validate changes with `swift build` or `swift test` before opening PRs.
- When exploring the codebase programmatically, prefer the Serena MCP server; for large cross‑file analysis, use the Gemini CLI (e.g., `gemini -p "@Sources/ Summarize modules"`).

