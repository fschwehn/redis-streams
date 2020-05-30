//
//  RedisHash.swift
//
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

public struct RedisHash: ExpressibleByDictionaryLiteral {
    
    internal var storage = [String : String]()
    
    public init(dictionaryLiteral elements: (String, CustomStringConvertible)...) {
        for element in elements {
            storage[element.0] = element.1.description
        }
    }
    
    public subscript<Value>(key: String) -> Value? where Value: LosslessStringConvertible {
        get {
            guard let stringValue = storage[key] else {
                return nil
            }
            
            return Value(stringValue)
        }
        set(newValue) {
            storage[key] = newValue?.description
        }
    }
    
    public func flattened() -> [RESPValue] {
        var list = [RESPValue]()
        list.reserveCapacity(storage.count * 2)

        for (key, value) in storage {
            list.append(.init(from: key))
            list.append(.init(from: value))
        }

        return list
    }
    
}

extension RedisHash: RESPValueConvertible {
    public init?(fromRESP value: RESPValue) {
        guard case .array(let list) = value else { return nil }
        guard list.count % 2 == 0 else { return nil }
        
        for fieldIndex in stride(from: 0, to: list.count, by: 2) {
            guard let field = String(fromRESP: list[fieldIndex]) else { return nil }
            guard let value = String(fromRESP: list[fieldIndex + 1]) else { return nil }
            
            storage[field] = value
        }
    }

    public func convertedToRESPValue() -> RESPValue {
        var list = [RESPValue]()
        list.reserveCapacity(storage.count * 2)
        
        for (key, value) in storage {
            list.append(.init(from: key))
            list.append(.init(from: value))
        }
        
        return .array(list)
    }
}

extension RedisHash: Equatable {}
