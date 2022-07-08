//
//  JSONDecoder+.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/08.
//

import Foundation

extension JSONDecoder {
    static func decode<T: Decodable>(_ type: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
