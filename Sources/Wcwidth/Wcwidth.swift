public struct Wcwidth: Hashable, Sendable {
    private let treatAmbiguousAsFullWidth: Bool

    public init(treatAmbiguousAsFullWidth: Bool = false) {
        self.treatAmbiguousAsFullWidth = treatAmbiguousAsFullWidth
    }

    public func callAsFunction(_ scalar: Unicode.Scalar) -> Int {
        let codePoint = scalar.value

        // Handle null character
        if codePoint == 0 {
            return 0
        }

        // Handle control characters (C0 and C1 control codes)
        if (codePoint < 32) || (codePoint >= 0x7F && codePoint < 0xA0) {
            return 0
        }

        // Handle DEL character
        if codePoint == 0x7F {
            return 0
        }

        // Check for zero-width characters first
        if UnicodeData.isGeneralCategory(of: codePoint, .nonspacingMark) ||
           UnicodeData.isGeneralCategory(of: codePoint, .enclosingMark) ||
           UnicodeData.isGeneralCategory(of: codePoint, .spacingCombiningMark) {
            return 0
        }

        // Handle specific zero-width characters
        if codePoint == 0x200B ||  // Zero Width Space
           codePoint == 0x200C ||  // Zero Width Non-Joiner
           codePoint == 0x200D ||  // Zero Width Joiner
           codePoint == 0x2060 ||  // Word Joiner
           codePoint == 0xFEFF {   // Zero Width No-Break Space
            return 0
        }

        // Get the East Asian Width property
        let eastAsianWidth = UnicodeData.eastAsianWidth(for: codePoint)

        switch eastAsianWidth {
        case .fullwidth, .wide:
            return 2
        case .halfwidth, .narrow, .neutral:
            // Additional check for emoji and symbols that should be wide
            if UnicodeData.isGeneralCategory(of: codePoint, .otherSymbol) {
                // Modern emoji and pictographic symbols are typically wide
                if (codePoint >= 0x1F000 && codePoint <= 0x1F9FF) ||  // Various emoji blocks
                   (codePoint >= 0x2600 && codePoint <= 0x27BF) {     // Misc symbols and dingbats
                    return 2
                }
            }
            return 1
        case .ambiguous:
            // Treat ambiguous characters based on flag
            return treatAmbiguousAsFullWidth ? 2 : 1
        case .none:
            return 1
        }
    }

    public func callAsFunction(_ character: Character) -> Int {
        // Fast path for single-scalar characters
        if character.unicodeScalars.count == 1,
           let scalar = character.unicodeScalars.first {
            return callAsFunction(scalar)
        }

        // For multi-scalar grapheme clusters, approximate the visual width as the
        // maximum width of any scalar in the cluster. This:
        // - yields 2 for emoji/ZWJ/flag sequences
        // - yields 1 for base+combining marks (combining marks are width 0)
        // - yields 0 if the cluster contains only zero-width marks
        var maxWidth = 0
        for scalar in character.unicodeScalars {
            let w = callAsFunction(scalar)
            if w > maxWidth { maxWidth = w }
            if maxWidth == 2 { break } // early-exit: cannot exceed 2 in our model
        }
        return maxWidth
    }

    public func callAsFunction(_ string: String) -> Int {
        var totalWidth = 0
        for character in string {
            totalWidth += callAsFunction(character)
        }
        return totalWidth
    }
}
