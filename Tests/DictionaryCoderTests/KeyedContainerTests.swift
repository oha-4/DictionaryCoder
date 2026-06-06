import XCTest
@testable import DictionaryCoder

/// Synthesized `Codable` encodes nested values through the generic
/// `encode<T>(_:forKey:)`, so a keyed container's `nestedContainer(forKey:)`,
/// `nestedUnkeyedContainer(forKey:)` and `superEncoder(forKey:)` are only
/// reached by a type that drives them explicitly.
private struct KeyedNesting: Codable, Equatable {
    var inner: Int
    var list: [Int]
    var sup: Int

    enum Keys: String, CodingKey { case inner, list, sup }
    enum InnerKeys: String, CodingKey { case v }

    init(inner: Int, list: [Int], sup: Int) {
        self.inner = inner
        self.list = list
        self.sup = sup
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Keys.self)
        var nested = c.nestedContainer(keyedBy: InnerKeys.self, forKey: .inner)
        try nested.encode(inner, forKey: .v)
        var unkeyed = c.nestedUnkeyedContainer(forKey: .list)
        for element in list { try unkeyed.encode(element) }
        let superEncoder = c.superEncoder(forKey: .sup)
        try sup.encode(to: superEncoder)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        let nested = try c.nestedContainer(keyedBy: InnerKeys.self, forKey: .inner)
        inner = try nested.decode(Int.self, forKey: .v)
        var unkeyed = try c.nestedUnkeyedContainer(forKey: .list)
        var arr = [Int]()
        while !unkeyed.isAtEnd { arr.append(try unkeyed.decode(Int.self)) }
        list = arr
        let superDecoder = try c.superDecoder(forKey: .sup)
        sup = try Int(from: superDecoder)
    }
}

final class KeyedContainerTests: XCTestCase {
    func testKeyedNestingRoundTrip() throws {
        try assertRoundTrip(KeyedNesting(inner: 5, list: [10, 20], sup: 7))
    }

    func testContainsAndAllKeys() throws {
        // Exercises the keyed container's allKeys / contains.
        struct Probe: Codable, Equatable {
            var present: Int
            init(present: Int) { self.present = present }
            init(from decoder: Decoder) throws {
                let c = try decoder.container(keyedBy: DictionaryCodingKey.self)
                XCTAssertTrue(c.contains(DictionaryCodingKey(stringValue: "present")))
                XCTAssertFalse(c.contains(DictionaryCodingKey(stringValue: "absent")))
                XCTAssertEqual(c.allKeys.map(\.stringValue), ["present"])
                present = try c.decode(Int.self, forKey: DictionaryCodingKey(stringValue: "present"))
            }
        }
        _ = try DictionaryDecoder().decode(Probe.self, from: ["present": 1])
    }
}
