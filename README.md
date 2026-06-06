# DictionaryCoder

[![CI](https://github.com/oha-4/DictionaryCoder/actions/workflows/ci.yml/badge.svg)](https://github.com/oha-4/DictionaryCoder/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/oha-4/DictionaryCoder/graph/badge.svg)](https://codecov.io/gh/oha-4/DictionaryCoder)

A Swift library to serialize `Codable` to and from `[String: DictionaryValue]`.

## Usage

```swift
struct User {
    let id: Int
    let name: String
    let age: Int?
}

let encoder = DictionaryEncoder()

let user0 = User(id: 0, name: "sheat")
let dictionary0 = try! encoder.encode(user0) as! [String: DictionaryValue]
// -> ["id": 0, "name": "sheat"]

let user1 = User(id: 1, name: "sheat", age: 21)
let dictionary1 = try! encoder.encode(user1) as! [String: DictionaryValue]
// -> ["id": 1, "name": "sheat", age: 21]


let decoder = DictionaryDecoder()

let _user0 = try! decoder.decode(User.self, from: dictionary0)
// -> User(id: 0, name: "sheat", age: nil)

let _user1 = try! decoder.decode(User.self, from: dictionary1)
// -> User(id: 1, name: "sheat", age: 21)
```

## DictionaryValue

This protocol applies to

- `Bool`
- `Int`
- `Float`
- `Double`
- `Decimal`
- `String`
- `Array` (`Element == DictionaryValue?`)
- `Dictionary` (`Key == String, Value == DictionaryValue?`)

## Notes & limitations

- **Integers** are stored as `Int`. All fixed-width integer types (`Int8` … `UInt64`) are
  accepted as long as the value fits in `Int`. A value outside that range (for example
  `UInt64.max`) throws `EncodingError.invalidValue` rather than crashing.
- **`Float`** is stored as `Float` (not widened to `Double`), so it round-trips with its own
  precision. `Double` is stored as `Double`.
- **Key strategies** match `JSONEncoder` / `JSONDecoder` exactly, including the well-known
  asymmetry for acronyms: `lastURL` encodes to `last_url`, which decodes back to `lastUrl`.

## EncodingStrategy / DecodingStrategy

The following options are available and can be used in the same way as JSONEncoder / JSONDecoder.

- DateEncodingStrategy / DateDecodingStrategy
- DataEncodingStrategy / DataDecodingStrategy
- KeyEncodingStrategy / KeyDecodingStrategy
