//
//  RedisType.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack
import Foundation

/// Represents different redis key types
public enum RedisType: String {
    case string
    case list
    case set
    case zset
    case hash
    case stream
    case none
    case unknown
}

extension RedisType: RESPValueConvertible {

    public init?(fromRESP value: RESPValue) {
        guard let raw = String(fromRESP: value) else { return nil }
        self = RedisType(rawValue: raw) ?? .unknown
    }

    public func convertedToRESPValue() -> RESPValue {
        return .init(from: rawValue)
    }

}

extension RedisType: RESPDecodable {}
