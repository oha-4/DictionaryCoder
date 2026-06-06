import XCTest

@testable import DictionaryCoder

/// Encodes `value` to a dictionary and decodes it back, asserting the result is equal.
func assertRoundTrip<T: Codable & Equatable>(
    _ value: T,
    encoder: DictionaryEncoder = DictionaryEncoder(),
    decoder: DictionaryDecoder = DictionaryDecoder(),
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    let encoded = try encoder.encode(value)
    let decoded = try decoder.decode(T.self, from: encoded)
    XCTAssertEqual(decoded, value, file: file, line: line)
}

struct AllIntegers: Codable, Equatable {
    let i: Int
    let i8: Int8
    let i16: Int16
    let i32: Int32
    let i64: Int64
    let u: UInt
    let u8: UInt8
    let u16: UInt16
    let u32: UInt32
    let u64: UInt64

    static let example = AllIntegers(
        i: -1, i8: .min, i16: .max, i32: -100, i64: 1_234_567_890,
        u: 1, u8: .max, u16: .max, u32: .max, u64: 9_000_000_000
    )
}

struct Scalars: Codable, Equatable {
    let bool: Bool
    let float: Float
    let double: Double
    let string: String
}

struct Item: Codable, Equatable {
    let id: Int
    let tags: [String]
}

struct Nested: Codable, Equatable {
    let items: [Item]
    let matrix: [[Int]]
    let lookup: [String: Int]
}

struct OptionalBox: Codable, Equatable {
    let a: Int
    let b: String?
}

struct UInt64Box: Codable, Equatable {
    let value: UInt64
}

struct Empty: Codable, Equatable {}
