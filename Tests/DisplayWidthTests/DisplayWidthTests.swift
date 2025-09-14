import Testing
import Foundation
@testable import DisplayWidth

@Test func testBasicDisplayWidth() throws {
    let displayWidth = DisplayWidth()

    // Basic ASCII characters should have width 1
    #expect(displayWidth("a") == 1)
    #expect(displayWidth("A") == 1)
    #expect(displayWidth("1") == 1)

    // Control characters should have width 0
    #expect(displayWidth("\u{0000}") == 0) // NULL
    #expect(displayWidth("\u{0001}") == 0) // Start of Heading
    #expect(displayWidth("\u{007F}") == 0) // DEL

    // Wide characters should have width 2
    #expect(displayWidth("あ") == 2) // Hiragana A
    #expect(displayWidth("中") == 2) // CJK character
}

@Test
func tsunodatahiro() async throws {
    #expect(DisplayWidth(treatAmbiguousAsFullWidth: true)("つのだ☆HIRO") == 12)
    #expect(DisplayWidth(treatAmbiguousAsFullWidth: false)("つのだ☆HIRO") == 11)
}

@Test func testAmbiguousCharacters() throws {
    let displayWidthNarrow = DisplayWidth(treatAmbiguousAsFullWidth: false)
    let displayWidthWide = DisplayWidth(treatAmbiguousAsFullWidth: true)

    // Test ambiguous characters (§ is ambiguous in East Asian Width)
    let ambiguousChar = "§" // Section sign
    #expect(displayWidthNarrow(ambiguousChar) == 1)
    #expect(displayWidthWide(ambiguousChar) == 2)
}

@Test func testAutoDetectionInit() throws {
    // Test that the auto-detection initializer works
    let displayWidthAuto = DisplayWidth()

    // Should work with basic characters
    #expect(displayWidthAuto("a") == 1)
    #expect(displayWidthAuto("中") == 2)
}

@Test func testLocaleAwareDisplayWidth() throws {
    // Test Japanese locale (should treat ambiguous as full-width)
    let japaneseLocale = Locale(identifier: "ja_JP")
    let displayWidthJP = LocaleAwareDisplayWidth(locale: japaneseLocale)

    // Test Korean locale (should treat ambiguous as full-width)
    let koreanLocale = Locale(identifier: "ko_KR")
    let displayWidthKR = LocaleAwareDisplayWidth(locale: koreanLocale)

    // Test Chinese locale (should treat ambiguous as full-width)
    let chineseLocale = Locale(identifier: "zh_CN")
    let displayWidthCN = LocaleAwareDisplayWidth(locale: chineseLocale)

    // Test English locale (should treat ambiguous as narrow)
    let englishLocale = Locale(identifier: "en_US")
    let displayWidthEN = LocaleAwareDisplayWidth(locale: englishLocale)

    // Ambiguous character test
    let ambiguousChar = "§" // Section sign
    #expect(displayWidthJP(ambiguousChar) == 2)
    #expect(displayWidthKR(ambiguousChar) == 2)
    #expect(displayWidthCN(ambiguousChar) == 2)
    #expect(displayWidthEN(ambiguousChar) == 1)

    // Regular characters should work the same
    #expect(displayWidthJP("a") == 1)
    #expect(displayWidthJP("中") == 2)
}

@Test func testEmojiWidths() throws {
    let displayWidth = DisplayWidth()

    // Basic emoji should be width 2
    #expect(displayWidth("😀") == 2) // Grinning face
    #expect(displayWidth("🌟") == 2) // Star
    #expect(displayWidth("🚀") == 2) // Rocket

    // Complex emoji sequences should be width 2
    #expect(displayWidth("👨‍💻") == 2) // Man technologist (ZWJ sequence)
    #expect(displayWidth("👩‍👩‍👧‍👦") == 2) // Family (complex ZWJ sequence)
    #expect(displayWidth("🏳️‍🌈") == 2) // Rainbow flag (ZWJ sequence)

    // Emoji with skin tone modifiers should be width 2
    #expect(displayWidth("👋🏽") == 2) // Waving hand with medium skin tone
    #expect(displayWidth("🤵🏿") == 2) // Person in tuxedo with dark skin tone

    // Flag emoji should be width 2
    #expect(displayWidth("🇺🇸") == 2) // US flag
    #expect(displayWidth("🇯🇵") == 2) // Japan flag
}

@Test func testVariationSelectors() throws {
    let displayWidth = DisplayWidth()

    // Variation selectors themselves should be width 0
    #expect(displayWidth("\u{FE0E}") == 0) // Text presentation selector
    #expect(displayWidth("\u{FE0F}") == 0) // Emoji presentation selector

    // Text with variation selectors
    #expect(displayWidth("➡️") == 2) // Right arrow with emoji selector
    #expect(displayWidth("➡︎") == 2) // Right arrow with text selector (still wide symbol)
}

@Test func testZeroWidthCharacters() throws {
    let displayWidth = DisplayWidth()

    // Zero-width characters should return 0
    #expect(displayWidth("\u{200B}") == 0) // Zero Width Space
    #expect(displayWidth("\u{200C}") == 0) // Zero Width Non-Joiner
    #expect(displayWidth("\u{200D}") == 0) // Zero Width Joiner
    #expect(displayWidth("\u{2060}") == 0) // Word Joiner
    #expect(displayWidth("\u{FEFF}") == 0) // Zero Width No-Break Space
}

@Test func testComplexGraphemeClusters() throws {
    let displayWidth = DisplayWidth()

    // Combining characters should not add width
    #expect(displayWidth("e\u{0301}") == 1) // e + combining acute accent
    #expect(displayWidth("ñ") == 1) // precomposed ñ
    #expect(displayWidth("n\u{0303}") == 1) // n + combining tilde

    // Thai combining characters
    #expect(displayWidth("ก\u{0E48}") == 1) // Thai character + tone mark

    // Multiple combining characters
    #expect(displayWidth("e\u{0301}\u{0302}") == 1) // e + acute + circumflex
}

@Test func testSymbolsAndDingbats() throws {
    let displayWidth = DisplayWidth()

    // Various symbols that should be wide
    #expect(displayWidth("⭐") == 2) // Star
    #expect(displayWidth("❤️") == 2) // Heart
    #expect(displayWidth("✨") == 2) // Sparkles
    #expect(displayWidth("📱") == 2) // Mobile phone
    #expect(displayWidth("🎯") == 2) // Target
}

@Test func testEdgeCases() throws {
    let displayWidth = DisplayWidth()

    // Control characters
    #expect(displayWidth("\0") == 0) // NULL
    #expect(displayWidth("\t") == 0) // Tab (control character)
    #expect(displayWidth("\n") == 0) // Newline (control character)
    #expect(displayWidth("\u{007F}") == 0) // DEL

    // Empty string
    #expect(displayWidth("") == 0)

    // Strings with mixed widths
    #expect(displayWidth("Hello 世界 🌍") == 13) // "Hello" (5) + " " (1) + "世界" (4) + " " (1) + "🌍" (2) = 13
}
