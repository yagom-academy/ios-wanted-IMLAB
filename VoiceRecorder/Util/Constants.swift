//
//  Constants.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/06.
//

import UIKit

struct CNS{
    
    struct autoLayout {
        static let waveFormHeightMP = CGFloat(0.3)
        static let standardWidthMP = CGFloat(0.8)
        static let standardConstant = UIScreen.main.bounds.height/30
        static let minConstant = UIScreen.main.bounds.height/50
    }
    
    struct size {
        static let playButton = UIScreen.main.bounds.height/25
        static let recordButton = UIScreen.main.bounds.height/16
        static let fileName = UIScreen.main.bounds.width/25
        static let tableViewRowHeight = UIScreen.main.bounds.height/18
        static let fileNamesInList = UIScreen.main.bounds.width/25
        static let time = UIScreen.main.bounds.width/13
    }
    
    struct sampleRate {
        static let max = Float(44100)
        static let min = Float(8000)
    }
    
    struct pitch {
        static let normal = "일반 목소리"
        static let baby = "아기 목소리"
        static let grandfather = "할아버지 목소리"
    }
    
}
