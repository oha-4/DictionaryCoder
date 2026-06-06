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
}

extension Bool: DictionaryValue {
    public var bool: Bool? { self }
}

extension Int: DictionaryValue {
    public var int: Int? { self }
}

extension Float: DictionaryValue {
    public var float: Float? { self }
    // A `Float` is also a valid floating-point source when a `Double` is requested.
    public var double: Double? { Double(self) }
}

extension Double: DictionaryValue {
    public var double: Double? { self }
}

extension Decimal: DictionaryValue {
    public var decimal: Decimal? { self }
}

extension String: DictionaryValue {
    public var string: String? { self }
}

extension Array: DictionaryValue where Element == DictionaryValue? {
    public var array: [DictionaryValue?]? { self }
}

extension Dictionary: DictionaryValue where Key == String, Value == DictionaryValue? {
    public var object: [String: DictionaryValue?]? { self }
}
