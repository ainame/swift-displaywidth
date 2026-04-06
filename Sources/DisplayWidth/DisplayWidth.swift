public struct DisplayWidth: Hashable, Sendable {
    private let treatAmbiguousAsFullWidth: Bool
    private let stripsANSI: Bool
    private let tabWidth: Int?

    public init(
        treatAmbiguousAsFullWidth: Bool = false,
        stripsANSI: Bool = false,
        tabWidth: Int? = nil
    ) {
        self.treatAmbiguousAsFullWidth = treatAmbiguousAsFullWidth
        self.stripsANSI = stripsANSI
        self.tabWidth = tabWidth
    }

    public func callAsFunction(_ string: String) -> Int {
        if !stripsANSI, tabWidth == nil {
            return measurePlainString(string)
        }

        return measureProcessedString(string)
    }

    private func measurePlainString(_ string: String) -> Int {
        var totalWidth = 0
        for character in string {
            totalWidth += callAsFunction(character)
        }
        return totalWidth
    }

    private func measureProcessedString(_ string: String) -> Int {
        var totalWidth = 0
        var index = string.startIndex

        while index < string.endIndex {
            if stripsANSI, let nextIndex = skipANSIEscapeSequence(in: string, from: index) {
                index = nextIndex
                continue
            }

            let character = string[index]
            if let tabWidth, character == "\t" {
                let remainder = totalWidth % tabWidth
                totalWidth += remainder == 0 ? tabWidth : tabWidth - remainder
                index = string.index(after: index)
                continue
            }

            totalWidth += callAsFunction(character)
            index = string.index(after: index)
        }

        return totalWidth
    }

    public func callAsFunction(_ character: Character) -> Int {
        // Fast path for single-scalar characters
        if character.unicodeScalars.count == 1,
           let scalar = character.unicodeScalars.first {
            return callAsFunction(scalar)
        }

        // Handle complex grapheme clusters
        return calculateGraphemeClusterWidth(character)
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
           codePoint == 0xFEFF ||  // Zero Width No-Break Space
           codePoint == 0xFE0E ||  // Variation Selector-15 (text presentation)
           codePoint == 0xFE0F {   // Variation Selector-16 (emoji presentation)
            return 0
        }

        // Get the East Asian Width property
        let eastAsianWidth = UnicodeData.eastAsianWidth(for: codePoint)

        switch eastAsianWidth {
        case .fullwidth, .wide:
            return 2
        case .halfwidth, .narrow, .neutral:
            // Check for emoji and symbols that should be wide
            if isWideSymbolOrEmoji(codePoint) {
                return 2
            }
            return 1
        case .ambiguous:
            // Treat ambiguous characters based on flag
            return treatAmbiguousAsFullWidth ? 2 : 1
        case .none:
            return 1
        }
    }

    private func isWideSymbolOrEmoji(_ codePoint: UInt32) -> Bool {
        // Comprehensive emoji and symbol ranges that should be wide
        return (codePoint >= 0x1F000 && codePoint <= 0x1F02F) ||  // Mahjong Tiles
               (codePoint >= 0x1F030 && codePoint <= 0x1F09F) ||  // Domino Tiles
               (codePoint >= 0x1F0A0 && codePoint <= 0x1F0FF) ||  // Playing Cards
               (codePoint >= 0x1F100 && codePoint <= 0x1F1FF) ||  // Enclosed Alphanumeric Supplement
               (codePoint >= 0x1F200 && codePoint <= 0x1F2FF) ||  // Enclosed Ideographic Supplement
               (codePoint >= 0x1F300 && codePoint <= 0x1F5FF) ||  // Miscellaneous Symbols and Pictographs
               (codePoint >= 0x1F600 && codePoint <= 0x1F64F) ||  // Emoticons
               (codePoint >= 0x1F650 && codePoint <= 0x1F67F) ||  // Ornamental Dingbats
               (codePoint >= 0x1F680 && codePoint <= 0x1F6FF) ||  // Transport and Map Symbols
               (codePoint >= 0x1F700 && codePoint <= 0x1F77F) ||  // Alchemical Symbols
               (codePoint >= 0x1F780 && codePoint <= 0x1F7FF) ||  // Geometric Shapes Extended
               (codePoint >= 0x1F800 && codePoint <= 0x1F8FF) ||  // Supplemental Arrows-C
               (codePoint >= 0x1F900 && codePoint <= 0x1F9FF) ||  // Supplemental Symbols and Pictographs
               (codePoint >= 0x1FA00 && codePoint <= 0x1FA6F) ||  // Chess Symbols
               (codePoint >= 0x1FA70 && codePoint <= 0x1FAFF) ||  // Symbols and Pictographs Extended-A
               (codePoint >= 0x2600 && codePoint <= 0x26FF) ||   // Miscellaneous Symbols
               (codePoint >= 0x2700 && codePoint <= 0x27BF) ||   // Dingbats
               (codePoint >= 0x2B50 && codePoint <= 0x2B59) ||   // Stars and other symbols
               (codePoint >= 0x3030 && codePoint <= 0x3030) ||   // Wavy dash
               (codePoint >= 0x3297 && codePoint <= 0x3297) ||   // Circled ideograph congratulation
               (codePoint >= 0x3299 && codePoint <= 0x3299) ||   // Circled ideograph secret
               (codePoint >= 0xFE4E && codePoint <= 0xFE4F)      // Centreline symbols
    }

    private func calculateGraphemeClusterWidth(_ character: Character) -> Int {
        let scalars = Array(character.unicodeScalars)

        // Handle flag sequences (two regional indicator symbols)
        if scalars.count == 2 &&
           scalars.allSatisfy({ isRegionalIndicator($0.value) }) {
            return 2
        }

        // Handle emoji ZWJ sequences and other complex emoji
        if containsEmoji(scalars) {
            return 2
        }

        // For other multi-scalar grapheme clusters, use maximum width approach
        // This handles base+combining marks correctly (combining marks are width 0)
        var maxWidth = 0
        for scalar in scalars {
            let w = callAsFunction(scalar)
            if w > maxWidth { maxWidth = w }
            if maxWidth == 2 { break } // early-exit: cannot exceed 2 in our model
        }
        return maxWidth
    }

    private func isRegionalIndicator(_ codePoint: UInt32) -> Bool {
        return codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF
    }

    private func containsEmoji(_ scalars: [Unicode.Scalar]) -> Bool {
        return scalars.contains { scalar in
            let codePoint = scalar.value
            return isWideSymbolOrEmoji(codePoint) ||
                   (codePoint >= 0x1F3FB && codePoint <= 0x1F3FF) || // Skin tone modifiers
                   codePoint == 0x200D || // ZWJ
                   codePoint == 0xFE0F    // Emoji variation selector
        }
    }

    private func skipANSIEscapeSequence(in string: String, from start: String.Index) -> String.Index? {
        guard string[start] == "\u{001B}" else {
            return nil
        }

        let introducerIndex = string.index(after: start)
        guard introducerIndex < string.endIndex else {
            return nil
        }

        switch string[introducerIndex] {
        case "[":
            return skipControlSequenceIntroducer(in: string, from: string.index(after: introducerIndex))
        case "]", "_":
            return skipStringTerminatedEscape(in: string, from: string.index(after: introducerIndex))
        default:
            return nil
        }
    }

    private func skipControlSequenceIntroducer(in string: String, from start: String.Index) -> String.Index? {
        var index = start

        while index < string.endIndex {
            let scalar = string[index].unicodeScalars.first!.value
            if scalar >= 0x40 && scalar <= 0x7E {
                return string.index(after: index)
            }
            index = string.index(after: index)
        }

        return nil
    }

    private func skipStringTerminatedEscape(in string: String, from start: String.Index) -> String.Index? {
        var index = start

        while index < string.endIndex {
            let character = string[index]
            if character == "\u{0007}" {
                return string.index(after: index)
            }

            if character == "\u{001B}" {
                let next = string.index(after: index)
                if next < string.endIndex, string[next] == "\\" {
                    return string.index(after: next)
                }
            }

            index = string.index(after: index)
        }

        return nil
    }
}
