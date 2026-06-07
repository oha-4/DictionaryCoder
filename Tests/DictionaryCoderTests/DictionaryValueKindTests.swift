import XCTest

@testable import DictionaryCoder

/// Verifies that every `DictionaryValue` conformer reports the expected ``DictionaryValueKind``
/// through ``DictionaryValue/kind``, so callers can `switch` over values exhaustively.
final class DictionaryValueKindTests: XCTestCase {
    func testScalarKinds() {
        guard case .bool(let b) = (true as DictionaryValue).kind, b == true else {
            return XCTFail("Bool should map to .bool")
        }
        guard case .int(let i) = (42 as DictionaryValue).kind, i == 42 else {
            return XCTFail("Int should map to .int")
        }
        guard case .float(let f) = (Float(0.25) as DictionaryValue).kind, f == 0.25 else {
            return XCTFail("Float should map to .float")
        }
        guard case .double(let d) = (Double(0.5) as DictionaryValue).kind, d == 0.5 else {
            return XCTFail("Double should map to .double")
        }
        guard case .decimal(let dec) = (Decimal(3) as DictionaryValue).kind, dec == 3 else {
            return XCTFail("Decimal should map to .decimal")
        }
        guard case .string(let s) = ("hi" as DictionaryValue).kind, s == "hi" else {
            return XCTFail("String should map to .string")
        }
    }

    /// `Float` also exposes `double`, but `kind` must stay `.float` so a single type maps to one
    /// stable case.
    func testFloatPrefersFloatOverDouble() {
        guard case .float = (Float(1.5) as DictionaryValue).kind else {
            return XCTFail("Float must report .float even though it also exposes `double`")
        }
    }

    func testArrayKind() {
        let array: [DictionaryValue?] = [1, "two", nil]
        guard case .array(let xs) = array.kind else {
            return XCTFail("Array should map to .array")
        }
        XCTAssertEqual(xs.count, 3)
        guard case .int(1) = xs[0]?.kind else { return XCTFail("element 0 should be .int(1)") }
        guard case .string("two") = xs[1]?.kind else { return XCTFail("element 1 should be .string") }
        XCTAssertNil(xs[2])
    }

    func testObjectKind() {
        let object: [String: DictionaryValue?] = ["n": 7]
        guard case .object(let o) = object.kind else {
            return XCTFail("Dictionary should map to .object")
        }
        guard case .int(7) = o["n"]??.kind else { return XCTFail("value should be .int(7)") }
    }

    /// A custom conformer that overrides nothing falls back to the default `nil` kind.
    func testUnknownKindDefaultsToNil() {
        struct Custom: DictionaryValue {}
        XCTAssertNil(Custom().kind)
    }
}
