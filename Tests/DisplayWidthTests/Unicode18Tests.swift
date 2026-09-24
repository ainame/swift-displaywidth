import Testing
@testable import DisplayWidth

// Examples from Unicode 18.0.0's new blocks and property data.
// https://www.unicode.org/versions/Unicode18.0.0/

@Test func unicode18NewScripts() {
    let displayWidth = DisplayWidth()

    // Proto-Cuneiform numerals are neutral; Jurchen and Seal are wide.
    #expect(displayWidth(Unicode.Scalar(0x12550)!) == 1)
    #expect(UnicodeData.isGeneralCategory(of: 0x12550, .letterNumber))
    #expect(UnicodeData.eastAsianWidth(for: 0x12550) == .neutral)
    #expect(displayWidth(Unicode.Scalar(0x18E50)!) == 2)
    #expect(UnicodeData.isGeneralCategory(of: 0x18E50, .otherLetter))
    #expect(UnicodeData.eastAsianWidth(for: 0x18E50) == .wide)
    #expect(displayWidth(Unicode.Scalar(0x3D123)!) == 2)
    #expect(UnicodeData.isGeneralCategory(of: 0x3D123, .otherLetter))
    #expect(UnicodeData.eastAsianWidth(for: 0x3D123) == .wide)
}

@Test func unicode18NewMarks() {
    let displayWidth = DisplayWidth()

    #expect(displayWidth(Unicode.Scalar(0x11DF0)!) == 0) // Bengali Supplement
    #expect(displayWidth(Unicode.Scalar(0x1ADE)!) == 0) // Combining grave-dot
    #expect(displayWidth(Unicode.Scalar(0x1D250)!) == 0) // Musical combining flag
    #expect(UnicodeData.isGeneralCategory(of: 0x1D250, .spacingCombiningMark))
}

@Test func unicode18NewSymbols() {
    let displayWidth = DisplayWidth()

    #expect(displayWidth(Unicode.Scalar(0x1FAC8)!) == 2) // Hairy creature emoji
    #expect(UnicodeData.isGeneralCategory(of: 0x1FAC8, .otherSymbol))
    #expect(UnicodeData.eastAsianWidth(for: 0x1FAC8) == .wide)
    #expect(displayWidth(Unicode.Scalar(0x20C2)!) == 1) // Rufiyaa sign
    #expect(UnicodeData.isGeneralCategory(of: 0x20C2, .currencySymbol))
}

@Test func unicode18FirstLastRangesIncludeInteriorsAndEndpoints() {
    // Both new scripts use First/Last pairs in UnicodeData.txt.
    for codepoint in [UInt32(0x18E00), 0x18E50, 0x19191, 0x3D000, 0x3D123, 0x3FC3F] {
        #expect(UnicodeData.isGeneralCategory(of: codepoint, .otherLetter))
    }

    // Existing paired ranges must remain complete after regeneration.
    #expect(UnicodeData.isGeneralCategory(of: 0xE001, .privateUse))
}
