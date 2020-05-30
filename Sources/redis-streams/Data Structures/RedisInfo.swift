//
//  RedisInfo.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

public struct RedisStreamInfo {
    public let length: Int
    public let radixTreeKeys: Int
    public let radixTreeNodes: Int
    public let groups: Int
    public let lastGeneratedId: String
    public let firstEntry: RedisStreamEntry?
    public let lastEntry: RedisStreamEntry?
}

extension RedisStreamInfo: RESPDecodable {
    
    public static func decode(_ value: RESPValue) throws -> RedisStreamInfo {
        do {
            let arr = try [RESPValue].decode(value)
            
            return .init(
                length: try arr.decodeKeyedValue(at: 0, expectedKey: "length"),
                radixTreeKeys: try arr.decodeKeyedValue(at: 2, expectedKey: "radix-tree-keys"),
                radixTreeNodes: try arr.decodeKeyedValue(at: 4, expectedKey: "radix-tree-nodes"),
                groups: try arr.decodeKeyedValue(at: 6, expectedKey: "groups"),
                lastGeneratedId: try arr.decodeKeyedValue(at: 8, expectedKey: "last-generated-id"),
                firstEntry: try arr.decodeKeyedValue(at: 10, expectedKey: "first-entry"),
                lastEntry: try arr.decodeKeyedValue(at: 12, expectedKey: "last-entry")
            )
        }
        catch {
            throw RESPDecodingError.complex(expectedType: RedisStreamInfo.self, value: value, underlyingError: error)
        }
    }
    
}

extension RedisStreamInfo: Equatable {}

public struct RedisGroupInfo {
    public let name: String
    public let consumers: Int
    public let pending: Int
    public let lastDeliveredId: String
}

extension RedisGroupInfo: Equatable {}

extension RedisGroupInfo: RESPDecodable {

    public static func decode(_ value: RESPValue) throws -> RedisGroupInfo {
        do {
            let arr = try [RESPValue].decode(value)
            
            return .init(
                name: try arr.decodeKeyedValue(at: 0, expectedKey: "name"),
                consumers: try arr.decodeKeyedValue(at: 2, expectedKey: "consumers"),
                pending: try arr.decodeKeyedValue(at: 4, expectedKey: "pending"),
                lastDeliveredId: try arr.decodeKeyedValue(at: 6, expectedKey: "last-delivered-id")
            )
        }
        catch {
            throw RESPDecodingError.complex(expectedType: [RedisGroupInfo].self, value: value, underlyingError: error)
        }
    }
    
}

public struct RedisConsumerInfo {
    public let name: String
    public let pending: Int
    public let idle: Int
}

extension RedisConsumerInfo: RESPDecodable {
    
    public static func decode(_ value: RESPValue) throws -> RedisConsumerInfo {
        let arr = try [RESPValue].decode(value)
        
        return .init(
            name: try arr.decodeKeyedValue(at: 0, expectedKey: "name"),
            pending: try arr.decodeKeyedValue(at: 2, expectedKey: "pending"),
            idle: try arr.decodeKeyedValue(at: 4, expectedKey: "idle")
        )
    }
    
}

extension RedisConsumerInfo: Equatable {}

