//
//  NanoID.swift
//

import Foundation

public final class NanoID: Identifiable, Hashable, Equatable, Codable, Sendable {
	public let string: String
	
	public init() {
		guard !NanoID.alphabet.isEmpty else { fatalError("Cannot use empty alphabet for NanoID") }
		let id = String((0 ..< NanoID.length).map { i in
			NanoID.alphabet.randomElement()!
		})
		self.string = id
	}
	
	public init(_ string: String) throws {
		guard string.count == NanoID.length else { throw Error.invalidIDStringLength }
		guard Set(string).isSubset(of: NanoID.alphabet) else { throw Error.invalidIDStringChars }
		self.string = string
	}
	
	
	public static var length: UInt = 21
	public static var alphabet: Set<Character> = Set("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-")
	
	
	public enum Error: Swift.Error {
		case invalidIDStringLength
		case invalidIDStringChars
	}
	
	// MARK: Codable
	public convenience init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let string = try container.decode(String.self)
		try self.init(string)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.string)
	}
	
	// MARK: Hashable
	public func hash(into hasher: inout Hasher) {
		hasher.combine(string)
	}
	
	// MARK: Equatable
	public static func == (lhs: NanoID, rhs: NanoID) -> Bool {
		lhs.string == rhs.string
	}
}

extension CharacterSet {
	func characters() -> [Character] {
		var codePoints: [Int] = []
		var plane = 0
		// following documentation at https://developer.apple.com/documentation/foundation/nscharacterset/1417719-bitmaprepresentation
		for (i, w) in bitmapRepresentation.enumerated() {
			let k = i % 0x2001
			if k == 0x2000 {
				// plane index byte
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
