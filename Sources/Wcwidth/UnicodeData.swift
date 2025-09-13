struct UnicodeData {
    static func generalCategory(for codepoint: UInt32) -> GeneralCategory? {
        // Check each category using binary search - order matters for performance
        if BinarySearch.find(codepoint, in: lu) { return .uppercaseLetter }
        if BinarySearch.find(codepoint, in: ll) { return .lowercaseLetter }
        if BinarySearch.find(codepoint, in: lt) { return .titlecaseLetter }
        if BinarySearch.find(codepoint, in: lm) { return .modifierLetter }
        if BinarySearch.find(codepoint, in: lo) { return .otherLetter }
        if BinarySearch.find(codepoint, in: mn) { return .nonspacingMark }
        if BinarySearch.find(codepoint, in: mc) { return .spacingCombiningMark }
        if BinarySearch.find(codepoint, in: me) { return .enclosingMark }
        if BinarySearch.find(codepoint, in: nd) { return .decimalDigitNumber }
        if BinarySearch.find(codepoint, in: nl) { return .letterNumber }
        if BinarySearch.find(codepoint, in: no) { return .otherNumber }
        if BinarySearch.find(codepoint, in: pc) { return .connectorPunctuation }
        if BinarySearch.find(codepoint, in: pd) { return .dashPunctuation }
        if BinarySearch.find(codepoint, in: ps) { return .openPunctuation }
        if BinarySearch.find(codepoint, in: pe) { return .closePunctuation }
        if BinarySearch.find(codepoint, in: pi) { return .initialQuotePunctuation }
        if BinarySearch.find(codepoint, in: pf) { return .finalQuotePunctuation }
        if BinarySearch.find(codepoint, in: po) { return .otherPunctuation }
        if BinarySearch.find(codepoint, in: sm) { return .mathSymbol }
        if BinarySearch.find(codepoint, in: sc) { return .currencySymbol }
        if BinarySearch.find(codepoint, in: sk) { return .modifierSymbol }
        if BinarySearch.find(codepoint, in: so) { return .otherSymbol }
        if BinarySearch.find(codepoint, in: zs) { return .spaceSeparator }
        if BinarySearch.find(codepoint, in: zl) { return .lineSeparator }
        if BinarySearch.find(codepoint, in: zp) { return .paragraphSeparator }
        if BinarySearch.find(codepoint, in: cc) { return .control }
        if BinarySearch.find(codepoint, in: cf) { return .format }
        if BinarySearch.find(codepoint, in: cs) { return .surrogate }
        if BinarySearch.find(codepoint, in: co) { return .privateUse }
        return nil
    }

    static func generalCategory(for scalar: UnicodeScalar) -> GeneralCategory? {
        return generalCategory(for: scalar.value)
    }

    static func eastAsianWidth(for codepoint: UInt32) -> EastAsianWidthAttribute? {
        // Check each property using binary search
        if BinarySearch.find(codepoint, in: ambiguous) { return .ambiguous }
        if BinarySearch.find(codepoint, in: fullwidth) { return .fullwidth }
        if BinarySearch.find(codepoint, in: halfwidth) { return .halfwidth }
        if BinarySearch.find(codepoint, in: neutral) { return .neutral }
        if BinarySearch.find(codepoint, in: narrow) { return .narrow }
        if BinarySearch.find(codepoint, in: wide) { return .wide }
        return nil
    }

    static func eastAsianWidth(for scalar: UnicodeScalar) -> EastAsianWidthAttribute? {
        return eastAsianWidth(for: scalar.value)
    }

    static func isGeneralCategory(of codepoint: UInt32, _ category: GeneralCategory) -> Bool {
        switch category {
        case .uppercaseLetter: return BinarySearch.find(codepoint, in: lu)
        case .lowercaseLetter: return BinarySearch.find(codepoint, in: ll)
        case .titlecaseLetter: return BinarySearch.find(codepoint, in: lt)
        case .modifierLetter: return BinarySearch.find(codepoint, in: lm)
        case .otherLetter: return BinarySearch.find(codepoint, in: lo)
        case .nonspacingMark: return BinarySearch.find(codepoint, in: mn)
        case .spacingCombiningMark: return BinarySearch.find(codepoint, in: mc)
        case .enclosingMark: return BinarySearch.find(codepoint, in: me)
        case .decimalDigitNumber: return BinarySearch.find(codepoint, in: nd)
        case .letterNumber: return BinarySearch.find(codepoint, in: nl)
        case .otherNumber: return BinarySearch.find(codepoint, in: no)
        case .connectorPunctuation: return BinarySearch.find(codepoint, in: pc)
        case .dashPunctuation: return BinarySearch.find(codepoint, in: pd)
        case .openPunctuation: return BinarySearch.find(codepoint, in: ps)
        case .closePunctuation: return BinarySearch.find(codepoint, in: pe)
        case .initialQuotePunctuation: return BinarySearch.find(codepoint, in: pi)
        case .finalQuotePunctuation: return BinarySearch.find(codepoint, in: pf)
        case .otherPunctuation: return BinarySearch.find(codepoint, in: po)
        case .mathSymbol: return BinarySearch.find(codepoint, in: sm)
        case .currencySymbol: return BinarySearch.find(codepoint, in: sc)
        case .modifierSymbol: return BinarySearch.find(codepoint, in: sk)
        case .otherSymbol: return BinarySearch.find(codepoint, in: so)
        case .spaceSeparator: return BinarySearch.find(codepoint, in: zs)
        case .lineSeparator: return BinarySearch.find(codepoint, in: zl)
        case .paragraphSeparator: return BinarySearch.find(codepoint, in: zp)
        case .control: return BinarySearch.find(codepoint, in: cc)
        case .format: return BinarySearch.find(codepoint, in: cf)
        case .surrogate: return BinarySearch.find(codepoint, in: cs)
        case .privateUse: return BinarySearch.find(codepoint, in: co)
        case .notAssigned: return false // cn not generated
        }
    }

    static func isGeneralCategory(of scalar: UnicodeScalar, _ category: GeneralCategory) -> Bool {
        return isGeneralCategory(of: scalar.value, category)
    }
}
