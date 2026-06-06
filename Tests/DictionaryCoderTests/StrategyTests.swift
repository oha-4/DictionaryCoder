import XCTest

@testable import DictionaryCoder

final class StrategyTests: XCTestCase {
    // A whole-second date so ISO8601 / formatter strategies (which drop sub-second precision) round-trip exactly.
    private let wholeSecondDate = Date(timeIntervalSince1970: 1_000_000)

    private struct DateBox: Codable, Equatable { let date: Date }
    private struct DataBox: Codable, Equatable { let data: Data }
    private struct CamelBox: Codable, Equatable {
        let firstName: String
        let lastName: String
    }

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

    func testDataCustom() throws {
        // Encode/decode Data as a hex string via custom closures.
        let encoder = DictionaryEncoder()
        encoder.dataEncodingStrategy = .custom { data, enc in
            var container = enc.singleValueContainer()
            try container.encode(data.map { String(format: "%02x", $0) }.joined())
        }
        let decoder = DictionaryDecoder()
        decoder.dataDecodingStrategy = .custom { dec in
            let hex = try dec.singleValueContainer().decode(String.self)
            var bytes = [UInt8]()
            var index = hex.startIndex
            while index < hex.endIndex {
                let next = hex.index(index, offsetBy: 2)
                bytes.append(UInt8(hex[index..<next], radix: 16)!)
                index = next
            }
            return Data(bytes)
        }
        try assertRoundTrip(DataBox(data: Data([0xDE, 0xAD, 0xBE, 0xEF])), encoder: encoder, decoder: decoder)
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

    func testSnakeCaseAcronymAndUnderscores() throws {
        // Exercises the multi-uppercase ("URL") and leading/trailing underscore
        // branches of the snake_case conversion.
        struct Keys: Codable, Equatable {
            let someURLValue: Int
            let _leading: Int
        }
        let encoder = DictionaryEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let encoded = try encoder.encode(Keys(someURLValue: 1, _leading: 2)) as! [String: DictionaryValue?]
        XCTAssertNotNil(encoded["some_url_value"])
        XCTAssertNotNil(encoded["_leading"])

        // convertFromSnakeCase with leading and trailing underscores.
        // swift-format-ignore: AlwaysUseLowerCamelCase
        struct Wrapped: Codable, Equatable { let _myValue_: Int }
        let decoder = DictionaryDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(Wrapped.self, from: ["_my_value_": 7])
        XCTAssertEqual(decoded._myValue_, 7)
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
