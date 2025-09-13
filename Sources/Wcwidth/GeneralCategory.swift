enum GeneralCategory: String, CaseIterable {
    case uppercaseLetter        // Lu - Letter, Uppercase
    case lowercaseLetter        // Ll - Letter, Lowercase
    case titlecaseLetter        // Lt - Letter, Titlecase
    case modifierLetter         // Lm - Letter, Modifier
    case otherLetter           // Lo - Letter, Other
    case nonspacingMark        // Mn - Mark, Nonspacing
    case spacingCombiningMark  // Mc - Mark, Spacing Combining
    case enclosingMark         // Me - Mark, Enclosing
    case decimalDigitNumber    // Nd - Number, Decimal Digit
    case letterNumber          // Nl - Number, Letter
    case otherNumber           // No - Number, Other
    case connectorPunctuation  // Pc - Punctuation, Connector
    case dashPunctuation       // Pd - Punctuation, Dash
    case openPunctuation       // Ps - Punctuation, Open
    case closePunctuation      // Pe - Punctuation, Close
    case initialQuotePunctuation // Pi - Punctuation, Initial quote
    case finalQuotePunctuation // Pf - Punctuation, Final quote
    case otherPunctuation      // Po - Punctuation, Other
    case mathSymbol            // Sm - Symbol, Math
    case currencySymbol        // Sc - Symbol, Currency
    case modifierSymbol        // Sk - Symbol, Modifier
    case otherSymbol           // So - Symbol, Other
    case spaceSeparator        // Zs - Separator, Space
    case lineSeparator         // Zl - Separator, Line
    case paragraphSeparator    // Zp - Separator, Paragraph
    case control               // Cc - Other, Control
    case format                // Cf - Other, Format
    case surrogate             // Cs - Other, Surrogate
    case privateUse            // Co - Other, Private Use
    case notAssigned           // Cn - Other, Not Assigned
}