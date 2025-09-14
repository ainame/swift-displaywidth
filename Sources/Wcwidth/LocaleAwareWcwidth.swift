#if canImport(Foundation)
import Foundation

public struct LocaleAwareWcwidth: Hashable, Sendable {
    private let wcwidth: Wcwidth

    public init(locale: Locale = Locale.current) {
        let treatAmbiguousAsFullWidth = Self.isEastAsianLocale(locale)
        self.wcwidth = Wcwidth(treatAmbiguousAsFullWidth: treatAmbiguousAsFullWidth)
    }

    private static func isEastAsianLocale(_ locale: Locale) -> Bool {
        // Use the older API that's compatible with earlier macOS versions
        guard let languageCode = locale.languageCode else {
            return false
        }

        // East Asian languages where ambiguous characters are typically full-width
        let eastAsianLanguages = ["ja", "ko", "zh"]

        if eastAsianLanguages.contains(languageCode) {
            return true
        }

        return false
    }

    public func callAsFunction(_ scalar: Unicode.Scalar) -> Int {
        return wcwidth(scalar)
    }

    public func callAsFunction(_ character: Character) -> Int {
        return wcwidth(character)
    }

    public func callAsFunction(_ string: String) -> Int {
        return wcwidth(string)
    }
}
#endif
