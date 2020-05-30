//
//  StreamResponseTypes.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

public struct RedisXPendingSimpleResponse {
    public let pending: Int
    public let smallestPendingId: String
    public let greatestPendingId: String
    public let consumers: [Consumer]

    public struct Consumer {
        public let name: String
        public let pending: Int
    }
}

extension RedisXPendingSimpleResponse: Equatable {}

extension RedisXPendingSimpleResponse.Consumer: Equatable {}

extension RedisXPendingSimpleResponse: RESPDecodableToOptional {

    public static func decode(_ value: RESPValue) throws -> RedisXPendingSimpleResponse? {
        do {
            let arr = try [RESPValue].decode(value)

            guard arr.count >= 4 else { throw RESPDecodingError.arrayOutOfBounds }

            let pending = try Int.decode(arr[0])

            guard pending > 0 else { return nil }

            let consumersArr = try [RESPValue].decode(arr[3])
            let consumers: [RedisXPendingSimpleResponse.Consumer] = try consumersArr.map {
                let consumerArr = try [RESPValue].decode($0)
                guard consumerArr.count >= 2 else { throw RESPDecodingError.arrayOutOfBounds }

                return RedisXPendingSimpleResponse.Consumer(
                    name: try .decode(consumerArr[0]),
                    pending: try .decode(consumerArr[1])
                )
            }

            return .init(
                pending: pending,
                smallestPendingId: try .decode(arr[1]),
                greatestPendingId: try .decode(arr[2]),
                consumers: consumers
            )
        }
        catch {
            throw RESPDecodingError.complex(expectedType: RedisXPendingSimpleResponse.self, value: value, underlyingError: error)
        }
    }

}

public struct RedisXPendingEntryInfo {
    public let id: String
    public let consumer: String
    public let millisecondsSinceLastDelivered: Int
    public let deliveryCount: Int
}

extension RedisXPendingEntryInfo: RESPDecodable {

    public static func decode(_ value: RESPValue) throws -> RedisXPendingEntryInfo {
        let arr = try [RESPValue].decode(value)

        guard arr.count >= 4 else { throw RESPDecodingError.arrayOutOfBounds }

        return Self(
            id: try String.decode(arr[0]),
            consumer: try String.decode(arr[1]),
            millisecondsSinceLastDelivered: try Int.decode(arr[2]),
            deliveryCount: try Int.decode(arr[3])
        )
    }

}

extension RedisXPendingEntryInfo: Equatable {}
