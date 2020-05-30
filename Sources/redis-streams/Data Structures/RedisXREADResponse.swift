//
//  RedisXREADResponse.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

public struct RedisXREADResponse {
    public typealias Storage = [String : [RedisStreamEntry]]
    
    public var storage = Storage()
    
    public subscript(key: String) -> [RedisStreamEntry]? {
        get {
            return storage[key]
        }
        set(newValue) {
            storage[key] = newValue
        }
    }
    
}

extension RedisXREADResponse: Sequence {
    public func makeIterator() -> Storage.Iterator {
        storage.makeIterator()
    }
}

extension RedisXREADResponse: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, [RedisStreamEntry])...) {
        for element in elements {
            storage[element.0] = element.1
        }
    }
    
}

extension RedisXREADResponse: RESPDecodable {
    
    public static func decode(_ value: RESPValue) throws -> RedisXREADResponse {
        var storage = [String : [RedisStreamEntry]]()
        
        if case .array(let streams) = value {
            for stream in streams {
                let values = try [RESPValue].decode(stream)
                
                guard values.count >= 2 else {
                    throw RESPDecodingError.arrayOutOfBounds
                }
                
                let key = try String.decode(values[0])
                let entries = try [RedisStreamEntry].decode(values[1])
                
                storage[key] = entries
            }
        }
        
        return .init(storage: storage)
    }
    
}

extension RedisXREADResponse: Equatable {}
