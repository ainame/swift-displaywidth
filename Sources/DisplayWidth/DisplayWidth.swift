public struct DisplayWidth: Hashable, Sendable {
    public enum Tab: Hashable, Sendable {
        case tabStops(Int)
        case fixedSpaces(Int)
    }

    private let treatAmbiguousAsFullWidth: Bool
    private let stripsANSI: Bool
    private let tab: Tab?

    public init(
        treatAmbiguousAsFullWidth: Bool = false,
        stripsANSI: Bool = false,
        tab: Tab? = nil
    ) {
        if let tab {
            switch tab {
            case let .tabStops(interval):
                precondition(interval > 0, "tab.tabStops interval must be greater than zero")
            case let .fixedSpaces(count):
                precondition(count > 0, "tab.fixedSpaces count must be greater than zero")
            }
        }
        self.treatAmbiguousAsFullWidth = treatAmbiguousAsFullWidth
        self.stripsANSI = stripsANSI
        self.tab = tab
    }

    public func callAsFunction(_ string: String) -> Int {
        if !stripsANSI, tab == nil {
            return measurePlainString(string)
        }

        return measureProcessedString(string)
    }

    private func measurePlainString<S: StringProtocol>(_ string: S) -> Int {
        var totalWidth = 0
        for character in string {
            totalWidth += callAsFunction(character)
        }
        return totalWidth
    }

    private func measureProcessedString(_ string: String) -> Int {
        var totalWidth = 0
        let scalars = string.unicodeScalars
        var scalarIndex = scalars.startIndex

        while scalarIndex < scalars.endIndex {
            let scalar = scalars[scalarIndex]

            if stripsANSI,
               scalar.value == 0x1B,
               let nextScalarIndex = skipANSIEscapeSequence(in: scalars, from: scalarIndex) {
                scalarIndex = nextScalarIndex
                continue
            }

            if let tab, scalar.value == 0x09 {
                totalWidth += widthForTab(tab, currentColumn: totalWidth)
                scalarIndex = scalars.index(after: scalarIndex)
                continue
            }

            let segmentStart = scalarIndex
            repeat {
                scalarIndex = scalars.index(after: scalarIndex)
            } while scalarIndex < scalars.endIndex && !isProcessingBoundary(scalars[scalarIndex])

            totalWidth += measurePlainString(string[segmentStart..<scalarIndex])
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
        var scalarCount = 0
        var allRegionalIndicators = true
        var maxWidth = 0
        for scalar in character.unicodeScalars {
            let codePoint = scalar.value
            scalarCount += 1
            allRegionalIndicators = allRegionalIndicators && isRegionalIndicator(codePoint)

            if isEmojiComponent(codePoint) {
                return 2
            }

            let width = callAsFunction(scalar)
            if width > maxWidth {
                maxWidth = width
                if maxWidth == 2 && scalarCount > 2 {
                    return 2
                }
            }
        }

        if scalarCount == 2 && allRegionalIndicators {
            return 2
        }

        return maxWidth
    }

    private func isRegionalIndicator(_ codePoint: UInt32) -> Bool {
        return codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF
    }

    private func isEmojiComponent(_ codePoint: UInt32) -> Bool {
        return isWideSymbolOrEmoji(codePoint) ||
               (codePoint >= 0x1F3FB && codePoint <= 0x1F3FF) || // Skin tone modifiers
               codePoint == 0x200D || // ZWJ
               codePoint == 0xFE0F    // Emoji variation selector
    }

    private func widthForTab(_ tab: Tab, currentColumn: Int) -> Int {
        switch tab {
        case let .tabStops(interval):
            let remainder = currentColumn % interval
            return remainder == 0 ? interval : interval - remainder
        case let .fixedSpaces(count):
            return count
        }
    }

    private func isProcessingBoundary(_ scalar: UnicodeScalar) -> Bool {
        (stripsANSI && scalar.value == 0x1B) || (tab != nil && scalar.value == 0x09)
    }

    private func skipANSIEscapeSequence(
        in scalars: String.UnicodeScalarView,
        from start: String.UnicodeScalarView.Index
    ) -> String.UnicodeScalarView.Index? {
        guard scalars[start].value == 0x1B else {
            return nil
        }

        let introducerIndex = scalars.index(after: start)
        guard introducerIndex < scalars.endIndex else {
            return nil
        }

        switch scalars[introducerIndex].value {
        case 0x5B: // [
            return skipControlSequenceIntroducer(in: scalars, from: scalars.index(after: introducerIndex))
        case 0x5D, 0x5F: // ], _
            return skipStringTerminatedEscape(in: scalars, from: scalars.index(after: introducerIndex))
        default:
            return nil
        }
    }

    private func skipControlSequenceIntroducer(
        in scalars: String.UnicodeScalarView,
        from start: String.UnicodeScalarView.Index
    ) -> String.UnicodeScalarView.Index? {
        var index = start

        while index < scalars.endIndex {
            let codePoint = scalars[index].value
            if codePoint >= 0x40 && codePoint <= 0x7E {
                return scalars.index(after: index)
            }
            index = scalars.index(after: index)
        }

        return nil
    }

    private func skipStringTerminatedEscape(
        in scalars: String.UnicodeScalarView,
        from start: String.UnicodeScalarView.Index
    ) -> String.UnicodeScalarView.Index? {
        var index = start

        while index < scalars.endIndex {
            let codePoint = scalars[index].value
            if codePoint == 0x07 { // BEL
                return scalars.index(after: index)
            }

            if codePoint == 0x1B {
                let next = scalars.index(after: index)
                if next < scalars.endIndex, scalars[next].value == 0x5C { // \
                    return scalars.index(after: next)
                }
            }

            index = scalars.index(after: index)
        }

        return nil
    }
}
