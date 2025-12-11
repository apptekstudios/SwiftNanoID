# SwiftNanoID

A tiny, secure, URL-friendly unique string ID generator for Swift.

[![Swift 5.10+](https://img.shields.io/badge/Swift-5.10+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

**SwiftNanoID** is a Swift implementation of the [NanoID](https://github.com/ai/nanoid) specification. It generates compact, URL-safe, unique identifiers that are perfect for use cases where UUIDs might be overkill or too verbose.

### Why NanoID?

| Feature | NanoID | UUID |
|---------|--------|------|
| Length | 21 characters | 36 characters |
| Entropy | ~126 bits | 122 bits |
| URL-safe | Yes | Requires encoding |
| Human-readable | More readable | Less readable |
| Customizable | Length & alphabet | No |

### Key Features

- **Compact** - Default 21 characters (vs UUID's 36)
- **URL-safe** - Uses only `A-Za-z0-9_-` characters
- **Secure** - Uses cryptographically secure random generation
- **Fast** - No external dependencies, minimal overhead
- **Customizable** - Configure length and character alphabet
- **Thread-safe** - Conforms to `Sendable` for safe concurrent use
- **Codable** - Full JSON encoding/decoding support
- **Type-safe** - Swift's type system ensures NanoID integrity

## Installation

### Swift Package Manager

Add SwiftNanoID to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/apptekstudios/SwiftNanoID.git", from: "1.0.0")
]
```

Then add `NanoID` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["NanoID"]
    )
]
```

### Xcode

1. Go to **File → Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/apptekstudios/SwiftNanoID.git`
3. Select your version requirements and add to your project

## Quick Start

```swift
import NanoID

// Generate a new NanoID
let id = NanoID()
print(id.string) // e.g., "V1StGXR8_Z5jdHi6B-myT"

// Use directly in string interpolation
print("User ID: \(id)")

// Parse an existing NanoID string
let existingId = try NanoID("V1StGXR8_Z5jdHi6B-myT")
```

## Usage

### Generating IDs

```swift
// Generate with default settings (21 characters, full alphabet)
let id = NanoID()
print(id.string) // "V1StGXR8_Z5jdHi6B-myT"
```

### Parsing and Validating

```swift
// Parse from a string (with validation)
do {
    let id = try NanoID("V1StGXR8_Z5jdHi6B-myT")
    print("Valid ID: \(id)")
} catch NanoID.Error.invalidIDStringLength {
    print("Invalid length")
} catch NanoID.Error.invalidIDStringChars {
    print("Invalid characters")
}
```

### Customizing Length

```swift
// Generate shorter IDs
NanoID.length = 12
let shortId = NanoID()
print(shortId.string) // "a1B2c3D4e5F6"

// Reset to default
NanoID.length = 21
```

### Customizing Alphabet

```swift
// Use only lowercase letters and numbers
NanoID.alphabet = Set("abcdefghijklmnopqrstuvwxyz0123456789")
let alphanumericId = NanoID()

// Use hexadecimal characters only
NanoID.alphabet = Set("0123456789abcdef")
let hexId = NanoID()

// Reset to default
NanoID.alphabet = Set("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-")
```

### Skipping Validation

For cases where you need to work with NanoID strings that don't conform to the current configuration:

```swift
// Create a NanoID without validation
let legacyId = NanoID.from(unchecked: "any-string-from-legacy-system")

// Works even if string doesn't match current length/alphabet
NanoID.length = 10
let longId = NanoID.from(unchecked: "this-is-much-longer-than-10-chars")
print(longId.string) // "this-is-much-longer-than-10-chars"
```

> **Warning**: No validation is performed. Use only when you trust the input source.

### Non-Strict Decoding Mode

When decoding NanoIDs from external sources (APIs, legacy databases), you can disable validation:

```swift
// Disable validation for decoding
NanoID.strict = false

let json = #"{"id":"legacy-id-different-format"}"#
let data = json.data(using: .utf8)!

struct Item: Decodable {
    let id: NanoID
}

// This would fail with strict=true, but succeeds with strict=false
let item = try JSONDecoder().decode(Item.self, from: data)

// Re-enable validation
NanoID.strict = true
```

> **Note**: The `strict` setting only affects `Codable` decoding. The throwing initializer `init(_:)` always validates.

### Using with Codable

NanoID seamlessly integrates with Swift's `Codable` protocol:

```swift
struct User: Codable {
    let id: NanoID
    let name: String
    let email: String
}

// Encoding
let user = User(id: NanoID(), name: "John Doe", email: "john@example.com")
let encoder = JSONEncoder()
let jsonData = try encoder.encode(user)
// {"id":"V1StGXR8_Z5jdHi6B-myT","name":"John Doe","email":"john@example.com"}

// Decoding
let decoder = JSONDecoder()
let decodedUser = try decoder.decode(User.self, from: jsonData)
print(decodedUser.id) // V1StGXR8_Z5jdHi6B-myT
```

### Using with SwiftUI

NanoID conforms to `Identifiable`, making it perfect for SwiftUI lists:

```swift
struct Item: Identifiable {
    let id: NanoID
    let title: String
}

struct ItemList: View {
    let items: [Item]

    var body: some View {
        List(items) { item in
            Text(item.title)
        }
    }
}
```

### Using in Collections

NanoID conforms to `Hashable` and `Equatable`:

```swift
// Use as dictionary keys
var userCache: [NanoID: User] = [:]
let userId = NanoID()
userCache[userId] = User(id: userId, name: "John")

// Use in sets
var processedIds: Set<NanoID> = []
processedIds.insert(NanoID())

// Compare NanoIDs
let id1 = NanoID()
let id2 = try NanoID(id1.string)
print(id1 == id2) // true
```

### Thread Safety

NanoID is `Sendable` and safe to use in concurrent contexts:

```swift
// Safe to use across async boundaries
func processInBackground() async {
    let id = NanoID()
    await Task.detached {
        print("Processing: \(id)")
    }.value
}

// Safe to generate from multiple threads
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    let id = NanoID()
    print(id)
}
```

## API Reference

### `NanoID`

The main class for generating and managing NanoIDs.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `string` | `String` | The string representation of the NanoID |
| `length` (static) | `UInt` | Length of generated IDs (default: 21) |
| `alphabet` (static) | `Set<Character>` | Characters used for generation |
| `strict` (static) | `Bool` | Enable/disable validation during decoding (default: true) |

#### Initializers & Factory Methods

| Method | Description |
|--------|-------------|
| `init()` | Creates a new random NanoID |
| `init(_ string: String) throws` | Creates a NanoID from an existing string (always validates) |
| `init(from decoder: Decoder) throws` | Decodes from JSON (validates when `strict` is true) |
| `from(unchecked: String)` | Creates a NanoID without validation |

#### Protocol Conformances

- `Identifiable` - Use as SwiftUI list item identifiers
- `Hashable` - Use as dictionary keys or in sets
- `Equatable` - Compare two NanoIDs for equality
- `Codable` - Encode/decode to JSON and other formats
- `Sendable` - Safe to use across concurrency boundaries
- `CustomStringConvertible` - Pretty-print with `print()` or string interpolation

### `NanoID.Error`

Errors thrown when parsing invalid NanoID strings.

| Case | Description |
|------|-------------|
| `invalidIDStringLength` | String length doesn't match `NanoID.length` |
| `invalidIDStringChars` | String contains characters not in `NanoID.alphabet` |

## Collision Probability

NanoID uses a 64-character alphabet by default. Here's how length affects collision probability:

| Length | Entropy (bits) | IDs for 1% collision probability |
|--------|----------------|----------------------------------|
| 21 (default) | 126 | ~1 billion |
| 16 | 96 | ~2 million |
| 12 | 72 | ~68,000 |
| 10 | 60 | ~1,000 |

### Entropy Formula

```
Entropy = length × log2(alphabet_size)
```

With the default 64-character alphabet:
- Each character provides 6 bits of entropy
- 21 characters × 6 bits = 126 bits total

This is comparable to UUID's 122 bits of entropy.

## Common Use Cases

### Database Primary Keys

```swift
struct Article: Codable {
    let id: NanoID
    let title: String
    let content: String
    let createdAt: Date

    init(title: String, content: String) {
        self.id = NanoID()
        self.title = title
        self.content = content
        self.createdAt = Date()
    }
}
```

### URL Slugs

```swift
// Generate short, URL-safe identifiers
NanoID.length = 10
let slug = NanoID()
let url = URL(string: "https://example.com/posts/\(slug)")!
// https://example.com/posts/a1B2c3D4e5
```

### Session Tokens

```swift
// Generate longer IDs for security-sensitive applications
NanoID.length = 32
let sessionToken = NanoID()
```

### File Names

```swift
func generateUniqueFileName(extension ext: String) -> String {
    let id = NanoID()
    return "\(id).\(ext)"
}

let fileName = generateUniqueFileName(extension: "png")
// "V1StGXR8_Z5jdHi6B-myT.png"
```

## Best Practices

### 1. Reset Configuration After Custom Use

```swift
// Store original values
let originalLength = NanoID.length
let originalAlphabet = NanoID.alphabet

// Custom configuration
NanoID.length = 10
let shortId = NanoID()

// Restore defaults
NanoID.length = originalLength
NanoID.alphabet = originalAlphabet
```

### 2. Use Error Handling for External Input

```swift
// Always validate user input
func processUserProvidedId(_ input: String) throws -> NanoID {
    return try NanoID(input)
}
```

### 3. Consider Entropy Requirements

Choose appropriate length based on your scale:

- **Small app** (< 10K records): Length 10-12 is sufficient
- **Medium app** (< 1M records): Length 16 recommended
- **Large app** (> 1M records): Keep default length 21

### 4. Use Type Safety

```swift
// Prefer NanoID type over raw strings
struct User {
    let id: NanoID  // ✓ Type-safe
    // let id: String  // ✗ Could be any string
}
```

## Requirements

- Swift 5.10+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Linux (with Swift 5.10+)

## License

SwiftNanoID is released under the MIT License. See [LICENSE](LICENSE) for details.

## Credits

- Original [NanoID](https://github.com/ai/nanoid) specification by Andrey Sitnik
- Swift implementation by [Apptek Studios](https://github.com/apptekstudios)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
