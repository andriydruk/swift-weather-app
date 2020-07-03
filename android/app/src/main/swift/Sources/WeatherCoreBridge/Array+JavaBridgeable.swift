//
// Created by Andrew on 1/11/18.
//

// TODO: remove this hack
#if os(Android)

import Foundation
import java_swift
import JavaCoder

public extension Array {

    // Decoding SwiftValue type with JavaCoder
    static func from<T>(javaObject: jobject) throws -> Array<T> where T: Decodable {
        // ignore forPackage for basic impl
        return try JavaDecoder(forPackage: "com.readdle.weather.core", missingFieldsStrategy: .ignore).decode(Array<T>.self, from: javaObject)
    }

}

public extension Array where Element: Encodable {

    // Encoding SwiftValue type with JavaCoder
    func javaObject() throws -> jobject {
        // ignore forPackage for basic impl
        return try JavaEncoder(forPackage: "com.readdle.weather.core", missingFieldsStrategy: .ignore).encode(self)
    }

}

#endif
