//
//  StreamCommands.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import NIO
import Foundation
import RediStack

extension RedisClient {
    
    @inlinable
    public func xack(_ key: String, group: String, ids: [String]) -> EventLoopFuture<Int> {
        var args: [RESPValue] = [
            .init(from: key),
            .init(from: group),
        ]
        
        args += ids.map(RESPValue.init)
        
        return send(command: "XACK", with: args)
            .decodeFromRESPValue()
    }
    
    ///
    /// Appends the specified stream entry to the stream at the specified key.
    /// [https://redis.io/commands/xadd](https://redis.io/commands/xadd)
    /// - Parameters:
    ///   - entry: The entry
    ///   - key: The stream key
    ///   - id: entry ID
    /// - Returns: The ID of the added entry
    @inlinable
    public func xadd(
        _ message: RedisHash,
        to key: String,
        id: String = "*"
    ) -> EventLoopFuture<String> {
        let args: [RESPValue] = [
            .init(from: key),
            .init(from: id),
        ]
            + message.flattened()
        
        return send(command: "XADD", with: args)
            .decodeFromRESPValue()
    }

    public func xclaim(
        _ key: String,
        group: String,
        consumer: String,
        minIdleTime: Int,
        ids: [String],
        idle: Int? = nil,
        time: Int? = nil,
        retryCount: Int? = nil,
        force: Bool = false,
        justId: Bool = false
    ) -> EventLoopFuture<[RedisStreamEntry]> {
        if ids.isEmpty {
            return eventLoop.makeSucceededFuture([])
        }
        
        var args = [RESPValue]()
        
        args.reserveCapacity(ids.count + 14)
        
        args.append(.init(from: key))
        args.append(.init(from: group))
        args.append(.init(from: consumer))
        args.append(.init(from: minIdleTime))
            
        args += ids.map(RESPValue.init)
        
        if let idle = idle {
            args.append(.init(from: "IDLE"))
            args.append(.init(from: idle))
        }
        
        if let time = time {
            args.append(.init(from: "TIME"))
            args.append(.init(from: time))
        }
        
        if let retryCount = retryCount {
            args.append(.init(from: "RETRYCOUNT"))
            args.append(.init(from: retryCount))
        }
        
        if let retryCount = retryCount {
            args.append(.init(from: "RETRYCOUNT"))
            args.append(.init(from: retryCount))
        }
        
        if force {
            args.append(.init(from: "FORCE"))
        }
        
        if justId {
            args.append(.init(from: "JUSTID"))
        }
        
        return send(command: "XCLAIM", with: args)
            .decodeFromRESPValue()
    }
    
    /// Removes the specified entries from a stream.
    /// - Parameter key: The stream's key
    /// - Returns: The number of entries deleted
    @inlinable
    public func xdel<T: Sequence>(_ key: String, ids: T) -> EventLoopFuture<Int> where T.Element == String {
        var args = [RESPValue(from: key)]
        
        for id in ids {
            args.append(id.convertedToRESPValue())
        }
        
        return send(command: "XDEL", with: args)
            .decodeFromRESPValue()
    }
    
    // MARK: Groups
    
    @inlinable
    public func xgroupCreate(_ key: String, group: String, id: String = "0", createStreamIfNotExists: Bool = false) -> EventLoopFuture<Bool> {
        var args: [RESPValue] = [
            .init(from: "CREATE"),
            .init(from: key),
            .init(from: group),
            .init(from: id)
        ]
        
        if createStreamIfNotExists {
            args.append(.init(from: "MKSTREAM"))
        }
        
        return send(command: "XGROUP", with: args)
            .decodeFromRESPValue(to: String.self)
            .map { $0 == "OK" }
    }
    
    @inlinable
    public func xgroupSetId(_ key: String, group: String, id: String) -> EventLoopFuture<Bool> {
        let args: [RESPValue] = [
            .init(from: "SETID"),
            .init(from: key),
            .init(from: group),
            .init(from: id)
        ]
        
        return send(command: "XGROUP", with: args)
            .decodeFromRESPValue(to: String.self)
            .map { $0 == "OK" }
    }
    
    @inlinable
    public func xgroupDestroy(_ key: String, group: String) -> EventLoopFuture<Int> {
        let args: [RESPValue] = [
            .init(from: "DESTROY"),
            .init(from: key),
            .init(from: group)
        ]
        
        return send(command: "XGROUP", with: args)
            .decodeFromRESPValue(to: Int.self)
    }
    
    @inlinable
    public func xgroupDelConsumer(_ key: String, group: String, consumer: String) -> EventLoopFuture<Int> {
        let args: [RESPValue] = [
            .init(from: "DELCONSUMER"),
            .init(from: key),
            .init(from: group),
            .init(from: consumer)
        ]
        
        return send(command: "XGROUP", with: args)
            .decodeFromRESPValue(to: Int.self)
    }
    
    @inlinable
    public func xgroupHelp() -> EventLoopFuture<[String]> {
        let args: [RESPValue] = [
            .init(from: "HELP")
        ]
        
        return send(command: "XGROUP", with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xinfoStream(_ key: String) -> EventLoopFuture<RedisStreamInfo> {
        let args = [
            RESPValue(from: "STREAM"),
            RESPValue(from: key),
        ]
        
        return send(command: "XINFO", with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xinfoGroups(_ key: String) -> EventLoopFuture<[RedisGroupInfo]> {
        let args = [
            RESPValue(from: "GROUPS"),
            RESPValue(from: key),
        ]
        
        return send(command: "XINFO", with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xinfoConsumers(_ key: String, group: String) -> EventLoopFuture<[RedisConsumerInfo]> {
        let args = [
            RESPValue(from: "CONSUMERS"),
            RESPValue(from: key),
            RESPValue(from: group),
        ]
        
        return send(command: "XINFO", with: args)
            .decodeFromRESPValue()
    }
    
    /// Returns the number of entries inside a stream
    /// - Parameter key: The stream's key
    @inlinable
    public func xlen(_ key: String) -> EventLoopFuture<Int> {
        let args = [RESPValue(from: key)]
        
        return send(command: "XLEN", with: args)
            .decodeFromRESPValue()
    }

    @inlinable
    public func xpending(_ key: String, group: String) -> EventLoopFuture<RedisXPendingSimpleResponse?> {
        let args = [
            RESPValue(from: key),
            RESPValue(from: group)
        ]
        
        return send(command: "XPENDING", with: args)
            .flatMapThrowing(RedisXPendingSimpleResponse.decode)
    }
    
    @inlinable
    public func xpending(_ key: String, group: String, smallestId: String, greatestId: String, count: Int, consumer: String? = nil) -> EventLoopFuture<[RedisXPendingEntryInfo]> {
        var args: [RESPValue] = [
            .init(from: key),
            .init(from: group),
            .init(from: smallestId),
            .init(from: greatestId),
            .init(from: count),
        ]
        
        if let consumer = consumer {
            args.append(.init(from: consumer))
        }
        
        return send(command: "XPENDING", with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xrange(
        _ key: String,
        start: String,
        end: String,
        count: Int? = nil,
        reverse: Bool = false
    ) -> EventLoopFuture<[RedisStreamEntry]> {
        var args: [RESPValue] = [
            .init(from: key),
            .init(from: start),
            .init(from: end),
        ]
        
        if let count = count {
            args.append(.init(from: "COUNT"))
            args.append(.init(from: count))
        }
        
        let command = reverse ? "XREVRANGE" : "XRANGE"
        
        return send(command: command, with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xrevrange(
        _ key: String,
        start: String,
        end: String,
        count: Int? = nil,
        reverse: Bool = false
    ) -> EventLoopFuture<[RedisStreamEntry]> {
        return xrange(key, start: start, end: end, count: count, reverse: true)
    }
    
    @inlinable
    public func xread(
        from streamPositions: [String : String],
        maxCount count: Int? = nil,
        blockFor milliseconds: Int? = nil
    ) -> EventLoopFuture<RedisXREADResponse> {
        var args = [RESPValue]()
        
        args.reserveCapacity(3 + streamPositions.count * 2)
        
        if let count = count {
            args += [
                .init(from: "COUNT"),
                .init(from: count)
            ]
        }
        
        if let milliseconds = milliseconds {
            args += [
                .init(from: "BLOCK"),
                .init(from: milliseconds)
            ]
        }
    
        args.append(.init(from: "STREAMS"))
        
        for key in streamPositions.keys {
            args.append(.init(from: key))
        }
        
        for id in streamPositions.values {
            args.append(.init(from: id))
        }
        
        return send(command: "XREAD", with: args)
            .decodeFromRESPValue()
    }
    
    // @TODO: we want a simplified variant that takes one stream key and one offset instead of a dicationary
    @inlinable
    public func xreadgroup(
        group: String,
        consumer: String,
        from streamPositions: [(String, String)],
        maxCount count: Int? = nil,
        blockFor milliseconds: Int? = nil
    ) -> EventLoopFuture<RedisXREADResponse> {
        var args: [RESPValue] = [
            .init(from: "GROUP"),
            .init(from: group),
            .init(from: consumer),
        ]
        
        args.reserveCapacity(6 + streamPositions.count * 2)
        
        if let count = count {
            args.append(.init(from: "COUNT"))
            args.append(.init(from: count))
        }
        
        if let milliseconds = milliseconds {
            args.append(.init(from: "BLOCK"))
            args.append(.init(from: milliseconds))
        }
    
        args.append(.init(from: "STREAMS"))
        
        for pos in streamPositions {
            args.append(.init(from: pos.0))
        }
        
        for pos in streamPositions {
            args.append(.init(from: pos.1))
        }
        
        return send(command: "XREADGROUP", with: args)
            .decodeFromRESPValue()
    }
    
    @inlinable
    public func xtrim(
        _ key: String,
        maxLength: Int,
        exact: Bool = false
    ) -> EventLoopFuture<Int> {
        var args = [RESPValue]()
        args.reserveCapacity(4)
        args.append(.init(from: key))
        args.append(.init(from: "MAXLEN"))
        
        if !exact {
            args.append(.init(from: "~"))
        }
        
        args.append(.init(from: maxLength))
        
        return send(command: "XTRIM", with: args)
            .decodeFromRESPValue()
    }
    
}
