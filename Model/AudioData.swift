//
//  AudioData.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

struct AudioData {
    
    static var Sample = AudioData(title: "2020_07_02_16:12:03", created_Date: Date(), playTime: "03:12", data: nil)
    
    var title: String
    var created_Date: Date
    var playTime: String
    var data: Data?
}
