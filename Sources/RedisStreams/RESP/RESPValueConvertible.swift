//
//  RESPValueConvertible.swift
//  
//
//  Created by Florian Schwehn on 30.05.20.
//

import RediStack

extension RESPValueConvertible {

    public static func decode(_ value: RESPValue) throws -> Self {
        guard let decoded = Self.init(fromRESP: value) else {
            throw RESPDecodingError.typeMismatch(expectedType: Self.self, value: value)
        }
        return decoded
    }

}
