import Testing
import Foundation
@testable import Wcwidth

@Test func testBasicWcwidth() throws {
    let wcwidth = Wcwidth()

    // Basic ASCII characters should have width 1
    #expect(wcwidth("a") == 1)
    #expect(wcwidth("A") == 1)
    #expect(wcwidth("1") == 1)

    // Control characters should have width 0
    #expect(wcwidth("\u{0000}") == 0) // NULL
    #expect(wcwidth("\u{0001}") == 0) // Start of Heading
    #expect(wcwidth("\u{007F}") == 0) // DEL

    // Wide characters should have width 2
    #expect(wcwidth("あ") == 2) // Hiragana A
    #expect(wcwidth("中") == 2) // CJK character
}

@Test
func tsunodatahiro() async throws {
    #expect(Wcwidth(treatAmbiguousAsFullWidth: true)("つのだ☆HIRO") == 12)
    #expect(Wcwidth(treatAmbiguousAsFullWidth: false)("つのだ☆HIRO") == 11)
}

@Test func testAmbiguousCharacters() throws {
    let wcwidthNarrow = Wcwidth(treatAmbiguousAsFullWidth: false)
    let wcwidthWide = Wcwidth(treatAmbiguousAsFullWidth: true)

    // Test ambiguous characters (§ is ambiguous in East Asian Width)
    let ambiguousChar = "§" // Section sign
    #expect(wcwidthNarrow(ambiguousChar) == 1)
    #expect(wcwidthWide(ambiguousChar) == 2)
}

@Test func testAutoDetectionInit() throws {
    // Test that the auto-detection initializer works
    let wcwidthAuto = Wcwidth()

    // Should work with basic characters
    #expect(wcwidthAuto("a") == 1)
    #expect(wcwidthAuto("中") == 2)
}

@Test func testLocaleAwareWcwidth() throws {
    // Test Japanese locale (should treat ambiguous as full-width)
    let japaneseLocale = Locale(identifier: "ja_JP")
    let wcwidthJP = LocaleAwareWcwidth(locale: japaneseLocale)

    // Test Korean locale (should treat ambiguous as full-width)
    let koreanLocale = Locale(identifier: "ko_KR")
    let wcwidthKR = LocaleAwareWcwidth(locale: koreanLocale)

    // Test Chinese locale (should treat ambiguous as full-width)
    let chineseLocale = Locale(identifier: "zh_CN")
    let wcwidthCN = LocaleAwareWcwidth(locale: chineseLocale)

    // Test English locale (should treat ambiguous as narrow)
    let englishLocale = Locale(identifier: "en_US")
    let wcwidthEN = LocaleAwareWcwidth(locale: englishLocale)

    // Ambiguous character test
    let ambiguousChar = "§" // Section sign
    #expect(wcwidthJP(ambiguousChar) == 2)
    #expect(wcwidthKR(ambiguousChar) == 2)
    #expect(wcwidthCN(ambiguousChar) == 2)
    #expect(wcwidthEN(ambiguousChar) == 1)

    // Regular characters should work the same
    #expect(wcwidthJP("a") == 1)
    #expect(wcwidthJP("中") == 2)
}

@Test func testEmojiWidths() throws {
    let wcwidth = Wcwidth()

    // Basic emoji should be width 2
    #expect(wcwidth("😀") == 2) // Grinning face
    #expect(wcwidth("🌟") == 2) // Star
    #expect(wcwidth("🚀") == 2) // Rocket

    // Complex emoji sequences should be width 2
    #expect(wcwidth("👨‍💻") == 2) // Man technologist (ZWJ sequence)
    #expect(wcwidth("👩‍👩‍👧‍👦") == 2) // Family (complex ZWJ sequence)
    #expect(wcwidth("🏳️‍🌈") == 2) // Rainbow flag (ZWJ sequence)

    // Emoji with skin tone modifiers should be width 2
    #expect(wcwidth("👋🏽") == 2) // Waving hand with medium skin tone
    #expect(wcwidth("🤵🏿") == 2) // Person in tuxedo with dark skin tone

    // Flag emoji should be width 2
    #expect(wcwidth("🇺🇸") == 2) // US flag
    #expect(wcwidth("🇯🇵") == 2) // Japan flag
}

@Test func testVariationSelectors() throws {
    let wcwidth = Wcwidth()

    // Variation selectors themselves should be width 0
    #expect(wcwidth("\u{FE0E}") == 0) // Text presentation selector
    #expect(wcwidth("\u{FE0F}") == 0) // Emoji presentation selector

    // Text with variation selectors
    #expect(wcwidth("➡️") == 2) // Right arrow with emoji selector
    #expect(wcwidth("➡︎") == 2) // Right arrow with text selector (still wide symbol)
}

@Test func testZeroWidthCharacters() throws {
    let wcwidth = Wcwidth()

    // Zero-width characters should return 0
    #expect(wcwidth("\u{200B}") == 0) // Zero Width Space
    #expect(wcwidth("\u{200C}") == 0) // Zero Width Non-Joiner
    #expect(wcwidth("\u{200D}") == 0) // Zero Width Joiner
    #expect(wcwidth("\u{2060}") == 0) // Word Joiner
    #expect(wcwidth("\u{FEFF}") == 0) // Zero Width No-Break Space
}

@Test func testComplexGraphemeClusters() throws {
    let wcwidth = Wcwidth()

    // Combining characters should not add width
    #expect(wcwidth("e\u{0301}") == 1) // e + combining acute accent
    #expect(wcwidth("ñ") == 1) // precomposed ñ
    #expect(wcwidth("n\u{0303}") == 1) // n + combining tilde

    // Thai combining characters
    #expect(wcwidth("ก\u{0E48}") == 1) // Thai character + tone mark

    // Multiple combining characters
    #expect(wcwidth("e\u{0301}\u{0302}") == 1) // e + acute + circumflex
}

@Test func testSymbolsAndDingbats() throws {
    let wcwidth = Wcwidth()

    // Various symbols that should be wide
    #expect(wcwidth("⭐") == 2) // Star
    #expect(wcwidth("❤️") == 2) // Heart
    #expect(wcwidth("✨") == 2) // Sparkles
    #expect(wcwidth("📱") == 2) // Mobile phone
    #expect(wcwidth("🎯") == 2) // Target
}

@Test func testEdgeCases() throws {
    let wcwidth = Wcwidth()

    // Control characters
    #expect(wcwidth("\0") == 0) // NULL
    #expect(wcwidth("\t") == 0) // Tab (control character)
    #expect(wcwidth("\n") == 0) // Newline (control character)
    #expect(wcwidth("\u{007F}") == 0) // DEL

    // Empty string
    #expect(wcwidth("") == 0)

    // Strings with mixed widths
    #expect(wcwidth("Hello 世界 🌍") == 13) // "Hello" (5) + " " (1) + "世界" (4) + " " (1) + "🌍" (2) = 13
}
