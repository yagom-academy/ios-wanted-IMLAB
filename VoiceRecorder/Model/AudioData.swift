//
//  AudioData.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

struct AudioData {
    
    static var Sample = AudioData(title: "2020_07_02_16:12:03", playTime: "03:12", data: nil)
    
    var title: String
    var playTime: String
    var data: Data?
}
