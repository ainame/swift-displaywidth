import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct UnicodeRange {
    let start: UInt32
    let end: UInt32
    let property: String
    let comment: String

    var isRange: Bool {
        return start != end
    }
}

@main
struct Command {
    static let unicodeVersion = "17.0.0"

    static func main() async throws {
        print("Downloading EastAsianWidth.txt...")
        let eastAsianData = try await downloadEastAsianWidth()

        print("Parsing EastAsianWidth.txt...")
        let eastAsianRanges = try parseEastAsianWidth(data: eastAsianData)

        print("Downloading UnicodeData.txt...")
        let unicodeData = try await downloadUnicodeData()

        print("Parsing UnicodeData.txt...")
        let generalCategoryRanges = try parseUnicodeData(data: unicodeData)

        print("Generating Swift code...")
        let swiftCode = generateSwiftCode(eastAsianRanges: eastAsianRanges, generalCategoryRanges: generalCategoryRanges)

        print("Writing generated Swift files...")
        try writeGeneratedFile(content: swiftCode)

        print("Done!")
    }

    static func downloadEastAsianWidth() async throws -> Data {
        let url = URL(string: "https://unicode.org/Public/\(unicodeVersion)/ucd/EastAsianWidth.txt")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    static func downloadUnicodeData() async throws -> Data {
        let url = URL(string: "https://unicode.org/Public/\(unicodeVersion)/ucd/UnicodeData.txt")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    static func parseEastAsianWidth(data: Data) throws -> [UnicodeRange] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data as UTF-8"])
        }

        var ranges: [UnicodeRange] = []

        for line in content.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }

            // Parse line format: "codepoint(s);property # comment"
            let parts = trimmedLine.components(separatedBy: ";")
            guard parts.count >= 2 else { continue }

            let codepointPart = parts[0].trimmingCharacters(in: .whitespaces)
            let propertyAndComment = parts[1].trimmingCharacters(in: .whitespaces)

            // Split property and comment
            let propertyParts = propertyAndComment.components(separatedBy: " # ")
            let property = propertyParts[0].trimmingCharacters(in: .whitespaces)
            let comment = propertyParts.count > 1 ? propertyParts[1] : ""

            // Parse codepoint or range
            if codepointPart.contains("..") {
                // Range format: "start..end"
                let rangeParts = codepointPart.components(separatedBy: "..")
                guard rangeParts.count == 2,
                      let start = UInt32(rangeParts[0], radix: 16),
                      let end = UInt32(rangeParts[1], radix: 16) else {
                    continue
                }
                ranges.append(UnicodeRange(start: start, end: end, property: property, comment: comment))
            } else {
                // Single codepoint
                guard let codepoint = UInt32(codepointPart, radix: 16) else {
                    continue
                }
                ranges.append(UnicodeRange(start: codepoint, end: codepoint, property: property, comment: comment))
            }
        }

        return ranges
    }

    static func parseUnicodeData(data: Data) throws -> [UnicodeRange] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data as UTF-8"])
        }

        var ranges: [UnicodeRange] = []

        for line in content.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }

            // Parse line format: "codepoint;name;category;..."
            let parts = trimmedLine.components(separatedBy: ";")
            guard parts.count >= 3 else { continue }

            let codepointPart = parts[0].trimmingCharacters(in: .whitespaces)
            let name = parts[1].trimmingCharacters(in: .whitespaces)
            let category = parts[2].trimmingCharacters(in: .whitespaces)

            guard let codepoint = UInt32(codepointPart, radix: 16) else {
                continue
            }

            ranges.append(UnicodeRange(start: codepoint, end: codepoint, property: category, comment: name))
        }

        return ranges
    }

    static func consolidateRanges(_ ranges: [UnicodeRange]) -> [UnicodeRange] {
        let sorted = ranges.sorted { $0.start < $1.start }
        var consolidated: [UnicodeRange] = []

        for range in sorted {
            if let last = consolidated.last,
               last.end + 1 >= range.start && last.property == range.property {
                // Merge with previous range
                consolidated[consolidated.count - 1] = UnicodeRange(
                    start: last.start,
                    end: max(last.end, range.end),
                    property: last.property,
                    comment: last.comment
                )
            } else {
                consolidated.append(range)
            }
        }

        return consolidated
    }

    static func generateSwiftCode(eastAsianRanges: [UnicodeRange], generalCategoryRanges: [UnicodeRange]) -> String {
        var code = """
// Generated from Unicode data files
// Unicode Version \(unicodeVersion)
// This file contains only pure Unicode data tables

extension UnicodeData {

"""

        // Generate General Category ranges
        let categories = Set(generalCategoryRanges.map { $0.property }).sorted()

        for category in categories {
            let categoryRanges = generalCategoryRanges.filter { $0.property == category }
            let consolidatedRanges = consolidateRanges(categoryRanges)

            let categoryDescription = getCategoryDescription(category)
            code += "\n    // \(categoryDescription)\n"
            code += "    static let \(category.lowercased()): [Range<UInt32>] = [\n"

            for range in consolidatedRanges {
                let rangeExpression: String
                if range.isRange {
                    rangeExpression = "0x\(String(range.start, radix: 16, uppercase: true))..<0x\(String(range.end + 1, radix: 16, uppercase: true))"
                } else {
                    rangeExpression = "0x\(String(range.start, radix: 16, uppercase: true))..<0x\(String(range.start + 1, radix: 16, uppercase: true))"
                }
                code += "        \(rangeExpression),\n"
            }

            code += "    ]\n"
        }

        // Generate EastAsianWidth ranges
        let eastAsianProperties = ["A", "F", "H", "N", "Na", "W"]

        for property in eastAsianProperties {
            let propertyRanges = eastAsianRanges.filter { $0.property == property }

            let propertyName = propertyDisplayName(property)
            code += "\n    // \(propertyName) (\(property))\n"
            code += "    static let \(propertyVariableName(property)): [Range<UInt32>] = [\n"

            for range in propertyRanges {
                let rangeExpression: String
                if range.isRange {
                    rangeExpression = "0x\(String(range.start, radix: 16, uppercase: true))..<0x\(String(range.end + 1, radix: 16, uppercase: true))"
                } else {
                    rangeExpression = "0x\(String(range.start, radix: 16, uppercase: true))..<0x\(String(range.start + 1, radix: 16, uppercase: true))"
                }

                let commentPart = range.comment.isEmpty ? "" : " // \(range.comment)"
                code += "        \(rangeExpression),\(commentPart)\n"
            }

            code += "    ]\n"
        }

        code += "}\n"

        return code
    }

    static func propertyDisplayName(_ property: String) -> String {
        switch property {
        case "A": return "Ambiguous"
        case "F": return "Fullwidth"
        case "H": return "Halfwidth"
        case "N": return "Neutral"
        case "Na": return "Narrow"
        case "W": return "Wide"
        default: return property
        }
    }

    static func propertyVariableName(_ property: String) -> String {
        switch property {
        case "A": return "ambiguous"
        case "F": return "fullwidth"
        case "H": return "halfwidth"
        case "N": return "neutral"
        case "Na": return "narrow"
        case "W": return "wide"
        default: return property.lowercased()
        }
    }

    static func getCategoryDescription(_ category: String) -> String {
        switch category {
        case "Lu": return "Letter, Uppercase"
        case "Ll": return "Letter, Lowercase"
        case "Lt": return "Letter, Titlecase"
        case "Lm": return "Letter, Modifier"
        case "Lo": return "Letter, Other"
        case "Mn": return "Mark, Nonspacing"
        case "Mc": return "Mark, Spacing Combining"
        case "Me": return "Mark, Enclosing"
        case "Nd": return "Number, Decimal Digit"
        case "Nl": return "Number, Letter"
        case "No": return "Number, Other"
        case "Pc": return "Punctuation, Connector"
        case "Pd": return "Punctuation, Dash"
        case "Ps": return "Punctuation, Open"
        case "Pe": return "Punctuation, Close"
        case "Pi": return "Punctuation, Initial quote"
        case "Pf": return "Punctuation, Final quote"
        case "Po": return "Punctuation, Other"
        case "Sm": return "Symbol, Math"
        case "Sc": return "Symbol, Currency"
        case "Sk": return "Symbol, Modifier"
        case "So": return "Symbol, Other"
        case "Zs": return "Separator, Space"
        case "Zl": return "Separator, Line"
        case "Zp": return "Separator, Paragraph"
        case "Cc": return "Other, Control"
        case "Cf": return "Other, Format"
        case "Cs": return "Other, Surrogate"
        case "Co": return "Other, Private Use"
        case "Cn": return "Other, Not Assigned"
        default: return "General Category: \(category)"
        }
    }

    static func writeGeneratedFile(content: String) throws {
        let url = URL(fileURLWithPath: "Sources/DisplayWidth/UnicodeData.generated.swift")
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
