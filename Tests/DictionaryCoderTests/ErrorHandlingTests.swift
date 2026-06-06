import XCTest
@testable import DictionaryCoder

final class ErrorHandlingTests: XCTestCase {
    private let decoder = DictionaryDecoder()

    func testTypeMismatch() throws {
        XCTAssertThrowsError(try decoder.decode(Int.self, from: "not a number")) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected typeMismatch, got \(error)")
            }
        }
    }

    func testBoolTypeMismatch() throws {
        XCTAssertThrowsError(try decoder.decode(Bool.self, from: 1)) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected typeMismatch, got \(error)")
            }
        }
    }

    func testKeyNotFound() throws {
        // `Item` requires both `id` and `tags`; `tags` is missing.
        let value: [String: DictionaryValue?] = ["id": 1]
        XCTAssertThrowsError(try decoder.decode(Item.self, from: value)) { error in
            guard case DecodingError.keyNotFound = error else {
                return XCTFail("Expected keyNotFound, got \(error)")
            }
        }
    }

    func testMissingOptionalKeyIsAllowed() throws {
        // A missing key for an Optional property decodes to nil (matches JSONDecoder).
        let value: [String: DictionaryValue?] = ["a": 1]
        let decoded = try decoder.decode(OptionalBox.self, from: value)
        XCTAssertEqual(decoded, OptionalBox(a: 1, b: nil))
    }

    func testValueNotFound() throws {
        // `a` is present but null, while the model requires a non-optional Int.
        let value: [String: DictionaryValue?] = ["a": nil, "b": "x"]
        XCTAssertThrowsError(try decoder.decode(OptionalBox.self, from: value)) { error in
            guard case DecodingError.valueNotFound = error else {
                return XCTFail("Expected valueNotFound, got \(error)")
            }
        }
    }

    func testDecodeIntegerOutOfRangeThrows() throws {
        // 300 does not fit in Int8.
        XCTAssertThrowsError(try decoder.decode(Int8.self, from: 300)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected dataCorrupted, got \(error)")
            }
        }
    }

    func testEncodeIntegerOverflowThrowsInsteadOfCrashing() throws {
        XCTAssertThrowsError(try DictionaryEncoder().encode(UInt64Box(value: .max))) { error in
            guard case EncodingError.invalidValue = error else {
                return XCTFail("Expected invalidValue, got \(error)")
            }
        }
    }

    func testKeyedContainerExpectedButArrayFound() throws {
        XCTAssertThrowsError(try decoder.decode(OptionalBox.self, from: [1, 2, 3])) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected typeMismatch, got \(error)")
            }
        }
    }

    func testUnkeyedContainerExpectedButObjectFound() throws {
        let value: [String: DictionaryValue?] = ["a": 1]
        XCTAssertThrowsError(try decoder.decode([Int].self, from: value)) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected typeMismatch, got \(error)")
            }
        }
    }

    func testInvalidISO8601Date() throws {
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .iso8601
        XCTAssertThrowsError(try decoder.decode(Date.self, from: "not a date")) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected dataCorrupted, got \(error)")
            }
        }
    }

    func testInvalidBase64Data() throws {
        let decoder = DictionaryDecoder()
        decoder.dataDecodingStrategy = .base64
        XCTAssertThrowsError(try decoder.decode(Data.self, from: "%%% not base64 %%%")) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected dataCorrupted, got \(error)")
            }
        }
    }

    func testUnkeyedContainerPastEnd() throws {
        // The dictionary has fewer elements than the type tries to decode.
        XCTAssertThrowsError(try decoder.decode([Int].self, from: ["x"])) { error in
            // Element 0 is a String, not an Int.
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected typeMismatch, got \(error)")
            }
        }
        XCTAssertThrowsError(try decoder.decode(NonEmptyPair.self, from: [1])) { error in
            guard case DecodingError.valueNotFound = error else {
                return XCTFail("Expected valueNotFound, got \(error)")
            }
        }
    }
}

/// Decodes two elements from an unkeyed container; used to trigger the
/// "container is at end" path when fewer elements are present.
private struct NonEmptyPair: Codable, Equatable {
    let a: Int
    let b: Int

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        a = try c.decode(Int.self)
        b = try c.decode(Int.self)
    }
}
