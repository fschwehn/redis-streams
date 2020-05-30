//
//  RedisStreamEntry.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

public struct RedisStreamEntry {
    public let id: String
    public let hash: RedisHash
}

extension RedisStreamEntry: RESPDecodable {

    public static func decode(_ value: RESPValue) throws -> RedisStreamEntry {
        let arr = try [RESPValue].decode(value)

        guard arr.count >= 2 else {
            throw RESPDecodingError.arrayOutOfBounds
        }
        
        return .init(
            id: try .decode(arr[0]),
            hash: try .decode(arr[1])
        )
    }

}

extension RedisStreamEntry: Equatable {}
