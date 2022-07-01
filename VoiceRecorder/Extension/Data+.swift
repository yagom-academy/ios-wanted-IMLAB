//
//  Data+.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import Foundation
import AVFoundation

extension Data {
    func getAVAudioFile() -> AVAudioFile {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).m4a"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        
        let audioFile = try! AVAudioFile(forReading: fullURL!)
        
        return audioFile
    }
}
