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
    
    func getFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let fileName = formatter.string(from: Date())
        return "voiceRecords_\(fileName)"
    }

}
