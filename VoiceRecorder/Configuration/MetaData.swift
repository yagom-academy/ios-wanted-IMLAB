//
//  MetaData.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/05.
//

import Foundation

enum MetaData: String {
    case duration
    case eq
    
    var key: String { self.rawValue }
}
