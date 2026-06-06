import XCTest
@testable import DictionaryCoder

/// `Array.encode(to:)` funnels through the generic `encode<T>` overload, so the
/// unkeyed container's concretely-typed encode/decode methods are only reached
/// by a type that drives an unkeyed container manually. These tests do exactly
/// that, covering every typed overload plus nesting and super coders.

/// Encodes one value of every scalar type into a single unkeyed container.
private struct UnkeyedScalars: Codable, Equatable {
    var bool: Bool
    var string: String
    var double: Double
    var float: Float
    var int: Int
    var int8: Int8
    var int16: Int16
    var int32: Int32
    var int64: Int64
    var uint: UInt
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64

    static let example = UnkeyedScalars(
        bool: true, string: "s", double: 0.5, float: 0.25,
        int: -1, int8: -8, int16: -16, int32: -32, int64: -64,
        uint: 1, uint8: 8, uint16: 16, uint32: 32, uint64: 64
    )

    func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        try c.encode(bool)
        try c.encode(string)
        try c.encode(double)
        try c.encode(float)
        try c.encode(int)
        try c.encode(int8)
        try c.encode(int16)
        try c.encode(int32)
        try c.encode(int64)
        try c.encode(uint)
        try c.encode(uint8)
        try c.encode(uint16)
        try c.encode(uint32)
        try c.encode(uint64)
    }

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        bool = try c.decode(Bool.self)
        string = try c.decode(String.self)
        double = try c.decode(Double.self)
        float = try c.decode(Float.self)
        int = try c.decode(Int.self)
        int8 = try c.decode(Int8.self)
        int16 = try c.decode(Int16.self)
        int32 = try c.decode(Int32.self)
        int64 = try c.decode(Int64.self)
        uint = try c.decode(UInt.self)
        uint8 = try c.decode(UInt8.self)
        uint16 = try c.decode(UInt16.self)
        uint32 = try c.decode(UInt32.self)
        uint64 = try c.decode(UInt64.self)
    }

    init(bool: Bool, string: String, double: Double, float: Float, int: Int, int8: Int8, int16: Int16, int32: Int32, int64: Int64, uint: UInt, uint8: UInt8, uint16: UInt16, uint32: UInt32, uint64: UInt64) {
        self.bool = bool; self.string = string; self.double = double; self.float = float
        self.int = int; self.int8 = int8; self.int16 = int16; self.int32 = int32; self.int64 = int64
        self.uint = uint; self.uint8 = uint8; self.uint16 = uint16; self.uint32 = uint32; self.uint64 = uint64
    }
}

/// Drives encodeNil/decodeNil on an unkeyed container.
private struct UnkeyedOptional: Codable, Equatable {
    var value: Int?

    init(value: Int?) { self.value = value }

    func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        if let value {
            try c.encode(value)
        } else {
            try c.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        if try c.decodeNil() {
            value = nil
        } else {
            value = try c.decode(Int.self)
        }
    }
}

/// Drives nestedContainer / nestedUnkeyedContainer / superEncoder on an unkeyed container.
private struct UnkeyedNesting: Codable, Equatable {
    var innerValue: Int
    var list: [Int]
    var sup: Int

    enum Inner: String, CodingKey { case v }

    init(innerValue: Int, list: [Int], sup: Int) {
        self.innerValue = innerValue
        self.list = list
        self.sup = sup
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        var keyed = c.nestedContainer(keyedBy: Inner.self)
        try keyed.encode(innerValue, forKey: .v)
        var unkeyed = c.nestedUnkeyedContainer()
        for element in list { try unkeyed.encode(element) }
        let superEncoder = c.superEncoder()
        try sup.encode(to: superEncoder)
    }

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        let keyed = try c.nestedContainer(keyedBy: Inner.self)
        innerValue = try keyed.decode(Int.self, forKey: .v)
        var unkeyed = try c.nestedUnkeyedContainer()
        var arr = [Int]()
        while !unkeyed.isAtEnd { arr.append(try unkeyed.decode(Int.self)) }
        list = arr
        let superDecoder = try c.superDecoder()
        sup = try Int(from: superDecoder)
    }
}

final class UnkeyedContainerTests: XCTestCase {
    func testTypedScalarsRoundTrip() throws {
        try assertRoundTrip(UnkeyedScalars.example)
    }

    func testUnkeyedNil() throws {
        try assertRoundTrip(UnkeyedOptional(value: 42))
        try assertRoundTrip(UnkeyedOptional(value: nil))
    }

    func testUnkeyedNesting() throws {
        try assertRoundTrip(UnkeyedNesting(innerValue: 7, list: [1, 2, 3], sup: 99))
    }
}
