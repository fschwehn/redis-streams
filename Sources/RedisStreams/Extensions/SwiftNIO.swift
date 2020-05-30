//
//  SwiftNIO.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import NIO
import RediStack

// MARK: EventLoopFuture RESPDecodable convenience

extension EventLoopFuture where Value == RESPValue {
    /// Attempts to decode the `RESPValue` to the desired `RESPDecodable` type.
    /// If the `RESPDcodable.decode(_:)` fails, then the `EventLoopFuture` will fail with the corresponding error.
    /// - Parameter to: The desired type to decode to.
    /// - Returns: An `EventLoopFuture` that resolves a value of the desired type.
    @inlinable
    public func decodeFromRESPValue<T>(
        to type: T.Type = T.self,
        file: StaticString = #function,
        function: StaticString = #function,
        line: UInt = #line
    )
        -> EventLoopFuture<T> where T: RESPDecodable
    {
        return self.flatMapThrowing {
            return try T.decode($0)
        }
    }
}
