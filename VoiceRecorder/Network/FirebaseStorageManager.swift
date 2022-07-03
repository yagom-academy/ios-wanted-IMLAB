//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/01.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    
    static var url = "gs://voicerecorder-d6222.appspot.com/2020_07_02.caf"
    
    static func download(urlString: String, completion: @escaping (Data?) -> Void) { // 싱글톤 유무
        Storage.storage().reference(forURL: urlString).downloadURL { url, error in
            guard let data = try? Data(contentsOf: url!) else {
                return
            }
            completion(data)
        }
    }
    
    
    static func uploadAudioFile() {
        guard let assetData = NSDataAsset.init(name: "sound")?.data else { return }
        StorageMetadata().contentType = "mp3"
        let audioName = UUID().uuidString + String(Date().timeIntervalSince1970)
    }
    
    
}
