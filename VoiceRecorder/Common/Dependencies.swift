//
//  Dependencies.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/07/08.
//

import Foundation

struct Dependencies {
    let audioRecoder: AudioRecordable
    let audioPlayer: AudioPlayable
    let firebaseStorageManager: FirebaseStorageManager
    let pathFinder: PathFinder
}
