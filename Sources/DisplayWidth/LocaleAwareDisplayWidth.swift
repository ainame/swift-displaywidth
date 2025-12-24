#if canImport(Foundation)
import Foundation

public struct LocaleAwareDisplayWidth: Hashable, Sendable {
    private let displayWidth: DisplayWidth

    public init(locale: Locale = Locale.current) {
        let treatAmbiguousAsFullWidth = Self.isEastAsianLocale(locale)
        self.displayWidth = DisplayWidth(treatAmbiguousAsFullWidth: treatAmbiguousAsFullWidth)
    }

    private static func isEastAsianLocale(_ locale: Locale) -> Bool {
        guard let languageCode = locale.language.languageCode?.identifier else {
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
        return displayWidth(scalar)
    }

    public func callAsFunction(_ character: Character) -> Int {
        return displayWidth(character)
    }

    public func callAsFunction(_ string: String) -> Int {
        return displayWidth(string)
    }
}
#endif
