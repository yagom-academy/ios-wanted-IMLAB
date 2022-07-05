//
//  AudioInfo.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation

import FirebaseStorage

struct AudioInfo {
    let id: String
    let data: Data?
    let metadata: StorageMetadata?
}



