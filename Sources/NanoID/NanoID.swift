//
//  NanoID.swift
//  SwiftNanoID
//
//  Copyright (c) 2024 Apptek Studios. All rights reserved.
//  Licensed under the MIT License. See LICENSE file for details.
//

import Foundation

/// A tiny, secure, URL-friendly unique string ID generator for Swift.
///
/// `NanoID` provides a simple and efficient way to generate unique identifiers that are:
/// - **Compact**: Default 21 characters (configurable)
/// - **URL-safe**: Uses only alphanumeric characters plus `_` and `-`
/// - **Secure**: Uses cryptographically secure random number generation
/// - **Fast**: Minimal overhead with no external dependencies
///
/// ## Overview
///
/// NanoID is a popular alternative to UUIDs when you need shorter, more readable identifiers.
/// With the default alphabet of 64 characters and length of 21, NanoID provides approximately
/// 126 bits of entropy, which is comparable to UUID's 122 bits.
///
/// ## Basic Usage
///
/// Generate a new random NanoID:
///
/// ```swift
/// let id = NanoID()
/// print(id.string) // e.g., "V1StGXR8_Z5jdHi6B-myT"
/// ```
///
/// Parse and validate an existing NanoID string:
///
/// ```swift
/// do {
///     let id = try NanoID("V1StGXR8_Z5jdHi6B-myT")
///     print(id.string)
/// } catch NanoID.Error.invalidIDStringLength {
///     print("Invalid length")
/// } catch NanoID.Error.invalidIDStringChars {
///     print("Invalid characters")
/// }
/// ```
///
/// ## Customization
///
/// You can customize the length and alphabet globally:
///
/// ```swift
/// // Use shorter IDs
/// NanoID.length = 12
///
/// // Use a custom alphabet (e.g., lowercase only)
/// NanoID.alphabet = Set("abcdefghijklmnopqrstuvwxyz")
///
/// let customId = NanoID()
/// print(customId.string) // e.g., "qwxyzabcdefg"
/// ```
///
/// ## Thread Safety
///
/// `NanoID` conforms to `Sendable` and is safe to use across concurrent contexts.
/// The underlying string is immutable after initialization.
///
/// ## Codable Support
///
/// `NanoID` can be encoded and decoded as a simple string value:
///
/// ```swift
/// struct User: Codable {
///     let id: NanoID
///     let name: String
/// }
///
/// let user = User(id: NanoID(), name: "John")
/// let json = try JSONEncoder().encode(user)
/// // {"id":"V1StGXR8_Z5jdHi6B-myT","name":"John"}
/// ```
///
/// ## Topics
///
/// ### Creating NanoIDs
///
/// - ``init()``
/// - ``init(_:)``
///
/// ### Configuration
///
/// - ``length``
/// - ``alphabet``
///
/// ### Accessing the Value
///
/// - ``string``
///
/// ### Error Handling
///
/// - ``Error``
///
public final class NanoID: Identifiable, Hashable, Equatable, Codable, Sendable {

    // MARK: - Properties

    /// The string representation of this NanoID.
    ///
    /// This is the unique identifier string that can be used for storage,
    /// transmission, or display purposes. The string is immutable and
    /// guaranteed to contain only characters from the configured ``alphabet``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id = NanoID()
    /// print(id.string) // e.g., "V1StGXR8_Z5jdHi6B-myT"
    ///
    /// // Use in URLs
    /// let url = URL(string: "https://example.com/items/\(id.string)")
    /// ```
    public let string: String

    // MARK: - Configuration

    /// The length of generated NanoID strings.
    ///
    /// This static property controls the length of all newly generated NanoIDs.
    /// The default value is `21`, which provides approximately 126 bits of entropy
    /// with the default 64-character alphabet.
    ///
    /// - Important: Changing this value affects all subsequent NanoID generation
    ///   and validation. Existing NanoID instances are not affected.
    ///
    /// - Warning: Shorter lengths reduce the entropy and increase collision probability.
    ///   Consider your uniqueness requirements when reducing this value.
    ///
    /// ## Collision Probability
    ///
    /// With the default 64-character alphabet:
    /// - Length 21: ~1 billion IDs needed for 1% collision probability
    /// - Length 16: ~2 million IDs needed for 1% collision probability
    /// - Length 10: ~1,000 IDs needed for 1% collision probability
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Generate shorter IDs for internal use
    /// NanoID.length = 12
    /// let shortId = NanoID()
    /// print(shortId.string.count) // 12
    ///
    /// // Reset to default
    /// NanoID.length = 21
    /// ```
    public static var length: UInt = 21

    /// The set of characters used to generate NanoID strings.
    ///
    /// This static property defines the character set (alphabet) from which
    /// NanoID characters are randomly selected. The default alphabet contains
    /// 64 URL-safe characters:
    ///
    /// - Digits: `0-9` (10 characters)
    /// - Lowercase letters: `a-z` (26 characters)
    /// - Uppercase letters: `A-Z` (26 characters)
    /// - Symbols: `_` and `-` (2 characters)
    ///
    /// - Important: Changing the alphabet affects all subsequent NanoID generation
    ///   and validation. Existing NanoID instances are not affected.
    ///
    /// - Warning: Using a smaller alphabet reduces entropy per character.
    ///   Consider increasing ``length`` to compensate.
    ///
    /// ## Entropy Calculation
    ///
    /// Entropy bits = length × log2(alphabet size)
    ///
    /// Examples with length 21:
    /// - 64 characters: 21 × 6 = 126 bits
    /// - 36 characters (alphanumeric): 21 × 5.17 ≈ 109 bits
    /// - 16 characters (hex): 21 × 4 = 84 bits
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Use only lowercase letters and numbers
    /// NanoID.alphabet = Set("abcdefghijklmnopqrstuvwxyz0123456789")
    ///
    /// // Use hexadecimal characters
    /// NanoID.alphabet = Set("0123456789abcdef")
    ///
    /// // Reset to default
    /// NanoID.alphabet = Set("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-")
    /// ```
    public static var alphabet: Set<Character> = Set("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-")

    // MARK: - Initialization

    /// Creates a new NanoID with a randomly generated string.
    ///
    /// Generates a unique identifier using the currently configured ``length``
    /// and ``alphabet``. Each character is selected randomly from the alphabet
    /// using Swift's built-in random number generator, which provides
    /// cryptographically secure randomness on supported platforms.
    ///
    /// - Precondition: ``alphabet`` must not be empty.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Generate with default settings
    /// let id1 = NanoID()
    ///
    /// // Generate with custom settings
    /// NanoID.length = 16
    /// NanoID.alphabet = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    /// let id2 = NanoID()
    /// print(id2.string) // e.g., "QWXYZABCDEFGHIJKL"
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This initializer is thread-safe. Multiple threads can generate
    /// NanoIDs concurrently without synchronization.
    public init() {
        guard !NanoID.alphabet.isEmpty else {
            fatalError("Cannot use empty alphabet for NanoID")
        }
        let id = String((0 ..< NanoID.length).map { _ in
            NanoID.alphabet.randomElement()!
        })
        self.string = id
    }

    /// Creates a NanoID from an existing string, validating its format.
    ///
    /// Use this initializer to parse and validate a NanoID string received
    /// from external sources such as APIs, databases, or user input.
    ///
    /// - Parameter string: The string to parse as a NanoID.
    ///
    /// - Throws: ``Error/invalidIDStringLength`` if the string length
    ///   doesn't match the configured ``length``.
    /// - Throws: ``Error/invalidIDStringChars`` if the string contains
    ///   characters not present in the configured ``alphabet``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Valid NanoID
    /// let id = try NanoID("V1StGXR8_Z5jdHi6B-myT")
    ///
    /// // Invalid length
    /// do {
    ///     let id = try NanoID("short")
    /// } catch NanoID.Error.invalidIDStringLength {
    ///     print("String must be exactly \(NanoID.length) characters")
    /// }
    ///
    /// // Invalid characters
    /// do {
    ///     let id = try NanoID("V1StGXR8_Z5jdHi6B-my!")
    /// } catch NanoID.Error.invalidIDStringChars {
    ///     print("String contains invalid characters")
    /// }
    /// ```
    ///
    /// ## Validation Rules
    ///
    /// The string must satisfy both conditions:
    /// 1. Length must equal ``length`` (default: 21)
    /// 2. All characters must be present in ``alphabet``
    public init(_ string: String) throws {
        guard string.count == NanoID.length else {
            throw Error.invalidIDStringLength
        }
        guard Set(string).isSubset(of: NanoID.alphabet) else {
            throw Error.invalidIDStringChars
        }
        self.string = string
    }

    // MARK: - Error Types

    /// Errors that can occur when parsing a NanoID from a string.
    ///
    /// These errors are thrown by ``init(_:)`` when the provided string
    /// doesn't conform to the expected NanoID format.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let id = try NanoID(userInput)
    /// } catch let error as NanoID.Error {
    ///     switch error {
    ///     case .invalidIDStringLength:
    ///         print("ID must be exactly \(NanoID.length) characters")
    ///     case .invalidIDStringChars:
    ///         print("ID contains invalid characters")
    ///     }
    /// }
    /// ```
    public enum Error: Swift.Error, CustomStringConvertible {

        /// The provided string length doesn't match the configured ``NanoID/length``.
        ///
        /// This error is thrown when attempting to create a NanoID from a string
        /// whose length differs from the expected length.
        case invalidIDStringLength

        /// The provided string contains characters not in the configured ``NanoID/alphabet``.
        ///
        /// This error is thrown when the string contains one or more characters
        /// that are not present in the allowed character set.
        case invalidIDStringChars

        /// A human-readable description of the error.
        public var description: String {
            switch self {
            case .invalidIDStringLength:
                return "Invalid NanoID string length. Expected \(NanoID.length) characters."
            case .invalidIDStringChars:
                return "Invalid NanoID string. Contains characters not in the allowed alphabet."
            }
        }
    }

    // MARK: - Codable

    /// Creates a NanoID by decoding from the given decoder.
    ///
    /// NanoID decodes from a single string value. This allows seamless
    /// integration with JSON and other serialization formats.
    ///
    /// - Parameter decoder: The decoder to read data from.
    ///
    /// - Throws: ``Error/invalidIDStringLength`` if the decoded string length
    ///   doesn't match the configured ``length``.
    /// - Throws: ``Error/invalidIDStringChars`` if the decoded string contains
    ///   invalid characters.
    /// - Throws: `DecodingError` if the value is not a valid string.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let json = #"{"id":"V1StGXR8_Z5jdHi6B-myT"}"#
    /// let data = json.data(using: .utf8)!
    ///
    /// struct Item: Decodable {
    ///     let id: NanoID
    /// }
    ///
    /// let item = try JSONDecoder().decode(Item.self, from: data)
    /// print(item.id.string) // "V1StGXR8_Z5jdHi6B-myT"
    /// ```
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }

    /// Encodes this NanoID into the given encoder.
    ///
    /// NanoID encodes as a single string value, making it compact and
    /// interoperable with any system that handles strings.
    ///
    /// - Parameter encoder: The encoder to write data to.
    ///
    /// - Throws: `EncodingError` if encoding fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Item: Encodable {
    ///     let id: NanoID
    ///     let name: String
    /// }
    ///
    /// let item = Item(id: NanoID(), name: "Example")
    /// let data = try JSONEncoder().encode(item)
    /// // {"id":"V1StGXR8_Z5jdHi6B-myT","name":"Example"}
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.string)
    }

    // MARK: - Hashable

    /// Hashes the essential components of this NanoID.
    ///
    /// The hash is computed from the underlying string value.
    ///
    /// - Parameter hasher: The hasher to use when combining the components.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }

    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two NanoIDs are equal.
    ///
    /// Two NanoIDs are considered equal if their string representations
    /// are identical.
    ///
    /// - Parameters:
    ///   - lhs: A NanoID to compare.
    ///   - rhs: Another NanoID to compare.
    ///
    /// - Returns: `true` if the NanoIDs have the same string value; otherwise, `false`.
    public static func == (lhs: NanoID, rhs: NanoID) -> Bool {
        lhs.string == rhs.string
    }
}

// MARK: - CustomStringConvertible

extension NanoID: CustomStringConvertible {
    /// A textual representation of this NanoID.
    ///
    /// Returns the underlying string value, making NanoID easy to use
    /// with string interpolation and print statements.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id = NanoID()
    /// print(id) // Prints the NanoID string directly
    /// print("User ID: \(id)") // Works with string interpolation
    /// ```
    public var description: String {
        string
    }
}

// MARK: - ExpressibleByStringLiteral

extension NanoID: ExpressibleByStringLiteral {
    /// Creates a NanoID from a string literal.
    ///
    /// This allows you to create NanoIDs using string literal syntax.
    /// Note that validation is performed at runtime, and invalid strings
    /// will cause a fatal error.
    ///
    /// - Warning: Use this only with known-valid NanoID strings.
    ///   For user input or external data, use ``init(_:)`` with error handling.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id: NanoID = "V1StGXR8_Z5jdHi6B-myT"
    /// ```
    ///
    /// - Parameter value: The string literal value.
    public convenience init(stringLiteral value: StringLiteralType) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid NanoID string literal: \(error)")
        }
    }
}

// MARK: - Internal Helpers

extension CharacterSet {
    /// Converts a CharacterSet to an array of Characters.
    ///
    /// This method iterates through the bitmap representation of the CharacterSet
    /// to extract all contained characters.
    ///
    /// - Returns: An array of all characters in the set.
    func characters() -> [Character] {
        var codePoints: [Int] = []
        var plane = 0
        // Following documentation at:
        // https://developer.apple.com/documentation/foundation/nscharacterset/1417719-bitmaprepresentation
        for (i, w) in bitmapRepresentation.enumerated() {
            let k = i % 0x2001
            if k == 0x2000 {
                // Plane index byte
                plane = Int(w) << 13
                continue
            }
            let base = (plane + k) << 3
            for j in 0 ..< 8 where w & 1 << j != 0 {
                codePoints.append(base + j)
            }
        }
        return codePoints.compactMap { UnicodeScalar($0) }.map { Character($0) }
    }
}
