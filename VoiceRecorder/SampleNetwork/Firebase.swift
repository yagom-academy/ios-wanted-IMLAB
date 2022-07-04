//
//  Firebase.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/04.
//

import Foundation
import FirebaseStorage

class Firebase {
    
    let storage = Storage.storage()
    
    func upload(url: URL) {
        let filePath = "recording_my_voice02.m4a"
        let data = try! Data(contentsOf: url)
        let metaData = StorageMetadata()
        metaData.contentType = "audio/x-m4a"
        
        storage.reference().child(filePath).putData(data, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("성공")
            }
        }
    }
}
