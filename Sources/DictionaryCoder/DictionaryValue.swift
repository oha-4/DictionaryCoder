//
//  DictionaryValue.swift
//
//
//  Created by sheat on 2023/01/17.
//

import Foundation

public protocol DictionaryValue {
    var bool: Bool? { get }
    var int: Int? { get }
    var float: Float? { get }
    var double: Double? { get }
    var decimal: Decimal? { get }
    var string: String? { get }
    var array: [DictionaryValue?]? { get }
    var object: [String: DictionaryValue?]? { get }
    var type: Self.Type { get }
    /// A concrete, switchable representation of this value.
    var kind: DictionaryValueKind? { get }
}

extension DictionaryValue {
    public var bool: Bool? { nil }
    public var int: Int? { nil }
    public var float: Float? { nil }
    public var double: Double? { nil }
    public var decimal: Decimal? { nil }
    public var string: String? { nil }
    public var array: [DictionaryValue?]? { nil }
    public var object: [String: DictionaryValue?]? { nil }
    public var type: Self.Type { Self.self }
    public var kind: DictionaryValueKind? { nil }
}

/// A type-safe view of a ``DictionaryValue`` suitable for exhaustive `switch` statements.
///
/// Obtain a value through ``DictionaryValue/kind``:
///
/// ```swift
/// switch value.kind {
/// case .int(let n):      print("int \(n)")
/// case .string(let s):   print("string \(s)")
/// case .array(let xs):   print("array of \(xs.count)")
/// case .object(let o):   print("object with keys \(o.keys)")
/// case .bool, .float, .double, .decimal:
///     break
/// case nil:
///     break // the value did not expose any known kind
/// }
/// ```
public enum DictionaryValueKind {
    case bool(Bool)
    case int(Int)
    case float(Float)
    case double(Double)
    case decimal(Decimal)
    case string(String)
    case array([DictionaryValue?])
    case object([String: DictionaryValue?])
}

extension Bool: DictionaryValue {
    public var bool: Bool? { self }
    public var kind: DictionaryValueKind? { .bool(self) }
}

extension Int: DictionaryValue {
    public var int: Int? { self }
    public var kind: DictionaryValueKind? { .int(self) }
}

extension Float: DictionaryValue {
    public var float: Float? { self }
    // A `Float` is also a valid floating-point source when a `Double` is requested.
    public var double: Double? { Double(self) }
    public var kind: DictionaryValueKind? { .float(self) }
}

extension Double: DictionaryValue {
    public var double: Double? { self }
    public var kind: DictionaryValueKind? { .double(self) }
}

extension Decimal: DictionaryValue {
    public var decimal: Decimal? { self }
    public var kind: DictionaryValueKind? { .decimal(self) }
}

extension String: DictionaryValue {
    public var string: String? { self }
    public var kind: DictionaryValueKind? { .string(self) }
}

extension Array: DictionaryValue where Element == DictionaryValue? {
    public var array: [DictionaryValue?]? { self }
    public var kind: DictionaryValueKind? { .array(self) }
}

extension Dictionary: DictionaryValue where Key == String, Value == DictionaryValue? {
    public var object: [String: DictionaryValue?]? { self }
    public var kind: DictionaryValueKind? { .object(self) }
}
