import Testing
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
