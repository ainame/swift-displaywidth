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

@Test func testWideSymbolsWithNeutralCategory() throws {
    let displayWidth = DisplayWidth()

    // Miscellaneous Symbols (2600-26FF) - These are neutral but should be wide
    #expect(displayWidth("☀") == 2) // Black sun with rays (U+2600)
    #expect(displayWidth("☁") == 2) // Cloud (U+2601)
    #expect(displayWidth("☂") == 2) // Umbrella (U+2602)
    #expect(displayWidth("☃") == 2) // Snowman (U+2603)
    #expect(displayWidth("☄") == 2) // Comet (U+2604)
    #expect(displayWidth("☔") == 2) // Umbrella with rain drops (U+2614)
    #expect(displayWidth("☕") == 2) // Hot beverage (U+2615)
    #expect(displayWidth("☘") == 2) // Shamrock (U+2618)
    #expect(displayWidth("☙") == 2) // Reversed rotated floral heart bullet (U+2619)
    #expect(displayWidth("☚") == 2) // Black left pointing index (U+261A)
    #expect(displayWidth("☛") == 2) // Black right pointing index (U+261B)

    // Dingbats (2700-27BF) - These are neutral but should be wide
    #expect(displayWidth("✀") == 2) // Black scissors (U+2700)
    #expect(displayWidth("✁") == 2) // Upper blade scissors (U+2701)
    #expect(displayWidth("✂") == 2) // Black scissors (U+2702)
    #expect(displayWidth("✃") == 2) // Lower blade scissors (U+2703)
    #expect(displayWidth("✄") == 2) // White scissors (U+2704)
    #expect(displayWidth("✅") == 2) // White heavy check mark (U+2705)
    #expect(displayWidth("✆") == 2) // Telephone location sign (U+2706)
    #expect(displayWidth("✇") == 2) // Tape drive (U+2707)
    #expect(displayWidth("✈") == 2) // Airplane (U+2708)
    #expect(displayWidth("✉") == 2) // Envelope (U+2709)
    #expect(displayWidth("✊") == 2) // Raised fist (U+270A)
    #expect(displayWidth("✋") == 2) // Raised hand (U+270B)
    #expect(displayWidth("✌") == 2) // Victory hand (U+270C)
    #expect(displayWidth("✍") == 2) // Writing hand (U+270D)
    #expect(displayWidth("✎") == 2) // Lower right pencil (U+270E)
    #expect(displayWidth("✏") == 2) // Pencil (U+270F)

    // Stars and special symbols from 2B50-2B59
    #expect(displayWidth("⭐") == 2) // White medium star (U+2B50)
    #expect(displayWidth("⭑") == 2) // Black small star (U+2B51)
    #expect(displayWidth("⭒") == 2) // White small star (U+2B52)
    #expect(displayWidth("⭓") == 2) // Black right-pointing pentagon (U+2B53)
    #expect(displayWidth("⭔") == 2) // White right-pointing pentagon (U+2B54)

    // Special symbols that should be wide
    #expect(displayWidth("〰") == 2) // Wavy dash (U+3030)
    #expect(displayWidth("㊗") == 2) // Circled ideograph congratulation (U+3297)
    #expect(displayWidth("㊙") == 2) // Circled ideograph secret (U+3299)

    // Centreline symbols (FE4E-FE4F)
    #expect(displayWidth("﹎") == 2) // Centreline low line (U+FE4E)
    #expect(displayWidth("﹏") == 2) // Centreline overline (U+FE4F)
}

@Test func testNeutralEmojisFromSpecialRanges() throws {
    let displayWidth = DisplayWidth()

    // Mahjong Tiles (1F000-1F02F) - neutral but should be wide
    #expect(displayWidth("🀀") == 2) // Mahjong tile east wind (U+1F000)
    #expect(displayWidth("🀁") == 2) // Mahjong tile south wind (U+1F001)
    #expect(displayWidth("🀂") == 2) // Mahjong tile west wind (U+1F002)
    #expect(displayWidth("🀃") == 2) // Mahjong tile north wind (U+1F003)
    #expect(displayWidth("🀄") == 2) // Mahjong tile red dragon (U+1F004)
    #expect(displayWidth("🀅") == 2) // Mahjong tile green dragon (U+1F005)
    #expect(displayWidth("🀆") == 2) // Mahjong tile white dragon (U+1F006)

    // Domino Tiles (1F030-1F09F) - neutral but should be wide
    #expect(displayWidth("🀰") == 2) // Domino tile horizontal back (U+1F030)
    #expect(displayWidth("🀱") == 2) // Domino tile horizontal-00-00 (U+1F031)
    #expect(displayWidth("🀲") == 2) // Domino tile horizontal-00-01 (U+1F032)
    #expect(displayWidth("🀳") == 2) // Domino tile horizontal-00-02 (U+1F033)
    #expect(displayWidth("🀴") == 2) // Domino tile horizontal-00-03 (U+1F034)
    #expect(displayWidth("🀵") == 2) // Domino tile horizontal-00-04 (U+1F035)
    #expect(displayWidth("🀶") == 2) // Domino tile horizontal-00-05 (U+1F036)

    // Playing Cards (1F0A0-1F0FF) - neutral but should be wide
    #expect(displayWidth("🂠") == 2) // Playing card back (U+1F0A0)
    #expect(displayWidth("🂡") == 2) // Playing card ace of spades (U+1F0A1)
    #expect(displayWidth("🂢") == 2) // Playing card two of spades (U+1F0A2)
    #expect(displayWidth("🂣") == 2) // Playing card three of spades (U+1F0A3)
    #expect(displayWidth("🂤") == 2) // Playing card four of spades (U+1F0A4)
    #expect(displayWidth("🂥") == 2) // Playing card five of spades (U+1F0A5)
    #expect(displayWidth("🂦") == 2) // Playing card six of spades (U+1F0A6)

    // Enclosed Ideographic Supplement (1F200-1F2FF) - testing specific chars that work
    #expect(displayWidth("🈀") == 2) // Square hiragana hoka (U+1F200)
    #expect(displayWidth("🈁") == 2) // Square katakana koko (U+1F201)
    #expect(displayWidth("🈂") == 2) // Squared katakana sa (U+1F202)
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
