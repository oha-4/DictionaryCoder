import XCTest
@testable import DictionaryCoder

final class RoundTripTests: XCTestCase {
    func testAllIntegerTypes() throws {
        try assertRoundTrip(AllIntegers.example)
    }

    func testScalars() throws {
        try assertRoundTrip(Scalars(bool: true, float: 0.1, double: 0.1, string: "hi"))
    }

    func testNested() throws {
        let value = Nested(
            items: [Item(id: 1, tags: ["a", "b"]), Item(id: 2, tags: [])],
            matrix: [[1, 2], [3, 4, 5], []],
            lookup: ["x": 1, "y": 2]
        )
        try assertRoundTrip(value)
    }

    func testOptionalPresentAndAbsent() throws {
        try assertRoundTrip(OptionalBox(a: 1, b: "set"))
        try assertRoundTrip(OptionalBox(a: 1, b: nil))
    }

    func testEmptyObject() throws {
        try assertRoundTrip(Empty())
    }

    func testTopLevelArray() throws {
        try assertRoundTrip([1, 2, 3])
        try assertRoundTrip([String]())
        try assertRoundTrip([[1], [2, 3]])
    }

    func testTopLevelScalar() throws {
        try assertRoundTrip(42)
        try assertRoundTrip("lonely string")
        try assertRoundTrip(true)
    }

    func testTopLevelNilEncodesToNil() throws {
        let value: Int? = nil
        XCTAssertNil(try DictionaryEncoder().encode(value))
    }

    // MARK: Type fidelity

    func testFloatIsStoredAsFloat() throws {
        let dict = try DictionaryEncoder().encode(Scalars(bool: false, float: 0.1, double: 0.2, string: "")) as! [String: DictionaryValue?]
        XCTAssertEqual(dict["float"] as? Float, Float(0.1))
        XCTAssertEqual(dict["double"] as? Double, Double(0.2))
        // A Float must not be silently widened to Double in the dictionary.
        XCTAssertNil(dict["float"] as? Double)
    }

    func testFloatPrecisionRoundTrips() throws {
        // 0.1 is not exactly representable; ensure the Float value survives the round trip.
        struct FloatBox: Codable, Equatable { let f: Float }
        try assertRoundTrip(FloatBox(f: 0.1))
        try assertRoundTrip(FloatBox(f: .greatestFiniteMagnitude))
    }

    // MARK: Class inheritance (super encoder / decoder)

    final class Derived: Base {
        let extra: String
        enum CodingKeys: String, CodingKey { case extra }

        init(base: Int, extra: String) {
            self.extra = extra
            super.init(base: base)
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            extra = try container.decode(String.self, forKey: .extra)
            try super.init(from: container.superDecoder())
        }

        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(extra, forKey: .extra)
            try super.encode(to: container.superEncoder())
        }
    }

    func testSuperEncoderRoundTrip() throws {
        let value = Derived(base: 7, extra: "child")
        let encoded = try DictionaryEncoder().encode(value)
        let decoded = try DictionaryDecoder().decode(Derived.self, from: encoded)
        XCTAssertEqual(decoded.base, 7)
        XCTAssertEqual(decoded.extra, "child")
    }
}

class Base: Codable {
    let base: Int
    init(base: Int) { self.base = base }
}
