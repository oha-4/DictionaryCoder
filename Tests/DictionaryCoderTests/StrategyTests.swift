import XCTest
@testable import DictionaryCoder

final class StrategyTests: XCTestCase {
    // A whole-second date so ISO8601 / formatter strategies (which drop sub-second precision) round-trip exactly.
    private let wholeSecondDate = Date(timeIntervalSince1970: 1_000_000)

    private struct DateBox: Codable, Equatable { let date: Date }
    private struct DataBox: Codable, Equatable { let data: Data }
    private struct CamelBox: Codable, Equatable { let firstName: String; let lastName: String }

    // MARK: Date strategies

    func testDateDeferredToDate() throws {
        try assertRoundTrip(DateBox(date: wholeSecondDate))
    }

    func testDateSecondsSince1970() throws {
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        try assertRoundTrip(DateBox(date: wholeSecondDate), encoder: encoder, decoder: decoder)
    }

    func testDateMillisecondsSince1970() throws {
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        try assertRoundTrip(DateBox(date: wholeSecondDate), encoder: encoder, decoder: decoder)
    }

    func testDateISO8601() throws {
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .iso8601
        try assertRoundTrip(DateBox(date: wholeSecondDate), encoder: encoder, decoder: decoder)
    }

    func testDateFormatted() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        try assertRoundTrip(DateBox(date: wholeSecondDate), encoder: encoder, decoder: decoder)
    }

    func testDateCustom() throws {
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .custom { date, enc in
            var container = enc.singleValueContainer()
            try container.encode(date.timeIntervalSince1970)
        }
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .custom { dec in
            let container = try dec.singleValueContainer()
            return Date(timeIntervalSince1970: try container.decode(Double.self))
        }
        try assertRoundTrip(DateBox(date: wholeSecondDate), encoder: encoder, decoder: decoder)
    }

    // MARK: Data strategies

    func testDataBase64() throws {
        try assertRoundTrip(DataBox(data: Data([0, 1, 2, 255])))
    }

    func testDataDeferredToData() throws {
        let encoder = DictionaryEncoder()
        encoder.dataEncodingStrategy = .deferredToData
        let decoder = DictionaryDecoder()
        decoder.dataDecodingStrategy = .deferredToData
        try assertRoundTrip(DataBox(data: Data([10, 20, 30])), encoder: encoder, decoder: decoder)
    }

    // MARK: Key strategies

    func testSnakeCaseRoundTrip() throws {
        let encoder = DictionaryEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = DictionaryDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let value = CamelBox(firstName: "Ada", lastName: "Lovelace")
        let encoded = try encoder.encode(value) as! [String: DictionaryValue?]
        XCTAssertNotNil(encoded["first_name"])
        XCTAssertNotNil(encoded["last_name"])

        let decoded = try decoder.decode(CamelBox.self, from: encoded)
        XCTAssertEqual(decoded, value)
    }

    func testCustomKeyStrategy() throws {
        let encoder = DictionaryEncoder()
        encoder.keyEncodingStrategy = .custom { path in
            DictionaryCodingKey(stringValue: path.last!.stringValue.uppercased())
        }
        let encoded = try encoder.encode(OptionalBox(a: 1, b: "x")) as! [String: DictionaryValue?]
        XCTAssertNotNil(encoded["A"])
        XCTAssertNotNil(encoded["B"])
    }
}
