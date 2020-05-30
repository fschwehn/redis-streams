import Foundation
import RediStack

public protocol RESPDecodable {
    
    static func decode(_ value: RESPValue) throws -> Self
    
}

public protocol RESPDecodableToOptional {
    
    static func decode(_ value: RESPValue) throws -> Self?
    
}

public enum RESPDecodingError: LocalizedError {
    case arrayOutOfBounds
    case keyMismatch(expected: String, actual: String)
    case typeMismatch(expectedType: Any.Type, value: RESPValue)
    case complex(expectedType: Any.Type, value: RESPValue, underlyingError: Error)
    
    public var errorDescription: String? {
        switch self {
        case .arrayOutOfBounds:
            return "RESPArray index out of range"
        case .keyMismatch(let expected, let actual):
            return "Expected key '\(expected)', found '\(actual)' instead"
        case .typeMismatch(let expectedType, let value):
            return "Failed to decode RESPValue to \(expectedType): \(value)"
        case .complex(let expectedType, let value, let underlyingError):
            return "Failed to decode RESPValue to \(expectedType): \(value), underlying error: \(underlyingError.localizedDescription)"
        }
    }
}

extension String: RESPDecodable {}

extension Int: RESPDecodable {}

extension Array where Element == RESPValue {

    public func decodeKeyedValue<Value: RESPDecodable>(at keyOffset: Int, expectedKey: String) throws -> Value {
        let valueOffset = keyOffset + 1

        guard count > valueOffset else {
            throw RESPDecodingError.arrayOutOfBounds
        }

        let key = try String.decode(self[keyOffset])

        guard key == expectedKey else {
            throw RESPDecodingError.keyMismatch(expected: expectedKey, actual: key)
        }

        return try .decode(self[valueOffset])
    }

}

extension Array: RESPDecodable where Element: RESPDecodable {

    public static func decode(_ value: RESPValue) throws -> Array<Element> {
        guard case .array(let arr) = value else {
            throw RESPDecodingError.typeMismatch(expectedType: Self.self, value: value)
        }
        return try arr.map(Element.decode)
    }

}
