//
//  RedisType.swift
//
//
//  Created by Florian Schwehn on 2020-05-31.
//

import NIO
import RediStack

extension RedisClient {
    /// Returns the `RedisType` of the value stored at key.
    /// If a key does not exist `RedisType.none` will be returned.
    /// - Parameter key:The key to get the type for
    @inlinable
    public func type(_ key: String) -> EventLoopFuture<RedisType> {
        let args = [RESPValue(from: key)]
        return send(command: "TYPE", with: args)
            .decodeFromRESPValue()
    }
}
