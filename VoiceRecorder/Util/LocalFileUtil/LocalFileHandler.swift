//
//  LocalFileHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

struct LocalFileHandler : LocalFileProtocol {
    
    var localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var localFileName: String {
        
        get {
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy. MM. dd HH:mm:ss"
            let fileName = formatter.string(from: date as Date)
            return fileName
        }
        
    }
    

}
