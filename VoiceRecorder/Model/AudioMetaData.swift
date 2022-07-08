//
//  AudioData.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

class AudioMetaData: Codable {
    var title: String
    var duration: String
    var url: String
    
    init(title: String, duration: String, url: String) {
        self.title = title
        self.duration = duration
        self.url = url
    }
}

