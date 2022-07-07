//
//  AudioData.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

class AudioData: Codable {
    
    var url: String
    var title: String
    var duration: String
    
    init(url: String ,title: String, duration: String) {
        self.title = title
        self.duration = duration
        self.url = url
    }
    
}

