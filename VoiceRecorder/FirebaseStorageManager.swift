//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/01.
//

import Foundation
import FirebaseStorage

class FirebaseStorageManager {
    static func upload() {
        
    }
    
    static func download() {
        Storage.storage().reference(forURL: "gs://voicerecorder-d6222.appspot.com/2022_07_01_16_26_42.mp3").downloadURL { url, error in
            let data = NSData(contentsOf: url!)
            print(data)
            print(error)
            print(url)
        }
    }
}
