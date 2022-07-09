//
//  FileData.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import Foundation

struct FileData: Codable {
    var rawFilename: String
    var filename: String
    var duration: String
}
