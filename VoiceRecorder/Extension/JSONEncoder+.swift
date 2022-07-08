//
//  JSONEncoder+.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/08.
//

import Foundation

extension JSONEncoder {
    static func encode<T: Encodable>(_ file: T) -> Data {
        do {
            return try JSONEncoder().encode(file)
        } catch {
            return Data()
        }
    }
}
