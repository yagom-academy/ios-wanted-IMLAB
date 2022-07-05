//
//  AudioData.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

class AudioData: Codable {
    
    var title: String
    var created_Date: Date
    var playTime: String
    var data: Data?
    
    init(title: String, created_Data: Date, playTime: String) {
        self.title = title
        self.created_Date = created_Data
        self.playTime = playTime
    }
    
}

