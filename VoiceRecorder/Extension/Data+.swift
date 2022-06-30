//
//  Data+.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import Foundation
import AVFoundation

extension Data {
    func getAVPlayerItem() -> AVPlayerItem {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).m4a"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        return playerItem
    }
}
