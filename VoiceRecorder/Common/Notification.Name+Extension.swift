//
//  Notification.Name+Extension.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/07/04.
//

import Foundation

extension Notification.Name {
    
    static let audioPlaybackTimeIsOver = Notification.Name.init(rawValue: "audioPlaybackTimeIsOver")
    static let recordFileUploadComplete =
    Notification.Name.init(rawValue: "recordViewUploadComplete")
    
}


