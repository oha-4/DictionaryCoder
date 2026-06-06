import XCTest
@testable import DictionaryCoder

/// Exercises every per-type encode/decode overload of the single-value and
/// unkeyed containers, plus the Foundation special-case types.
final class ScalarCoverageTests: XCTestCase {
    // MARK: Top-level scalars -> single-value containers

    func testTopLevelIntegers() throws {
        try assertRoundTrip(Int(-1))
        try assertRoundTrip(Int8(-8))
        try assertRoundTrip(Int16(-16))
        try assertRoundTrip(Int32(-32))
        try assertRoundTrip(Int64(-64))
        try assertRoundTrip(UInt(1))
        try assertRoundTrip(UInt8(8))
        try assertRoundTrip(UInt16(16))
        try assertRoundTrip(UInt32(32))
        try assertRoundTrip(UInt64(64))
    }

    func testTopLevelFloatingAndBool() throws {
        try assertRoundTrip(Float(0.25))
        try assertRoundTrip(Double(0.5))
        try assertRoundTrip(true)
        try assertRoundTrip(false)
    }

    func testTopLevelFoundationScalars() throws {
        try assertRoundTrip(Decimal(string: "3.14")!)
        try assertRoundTrip(URL(string: "https://example.com/path?q=1")!)
        try assertRoundTrip(Date(timeIntervalSince1970: 1_000_000))
        try assertRoundTrip(Data([1, 2, 3, 4]))
    }

    func testTopLevelOptionalNil() throws {
        let value: Int? = nil
        let encoded = try DictionaryEncoder().encode(value)
        XCTAssertNil(encoded)
        let decoded = try DictionaryDecoder().decode(Int?.self, from: encoded)
        XCTAssertNil(decoded)
    }

    // MARK: Arrays -> unkeyed containers

    func testArraysOfEachIntegerType() throws {
        try assertRoundTrip([Int8(1), -2, 3])
        try assertRoundTrip([Int16(1), -2])
        try assertRoundTrip([Int32(1), -2])
        try assertRoundTrip([Int64(1), -2])
        try assertRoundTrip([Int(1), -2])
        try assertRoundTrip([UInt(1), 2])
        try assertRoundTrip([UInt8(1), 2])
        try assertRoundTrip([UInt16(1), 2])
        try assertRoundTrip([UInt32(1), 2])
        try assertRoundTrip([UInt64(1), 2])
    }

    func testArraysOfOtherScalars() throws {
        try assertRoundTrip([Float(0.25), 0.5])
        try assertRoundTrip([Double(0.25), 0.5])
        try assertRoundTrip([true, false, true])
        try assertRoundTrip(["a", "b"])
        try assertRoundTrip([Decimal(1), Decimal(2)])
    }

    func testArrayWithNilElements() throws {
        let value: [Int?] = [1, nil, 3]
        try assertRoundTrip(value)
    }

    // MARK: Nested unkeyed / arrays of objects

    func testNestedArraysAndObjectArrays() throws {
        try assertRoundTrip([[1, 2], [3], []])

        struct Point: Codable, Equatable { let x: Int; let y: Int }
        try assertRoundTrip([Point(x: 1, y: 2), Point(x: 3, y: 4)])
        try assertRoundTrip([[Point(x: 1, y: 2)], [Point(x: 3, y: 4)]])
    }
}
