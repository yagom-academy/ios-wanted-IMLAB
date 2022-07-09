//
//  UploadRecordfile.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/28.
//

import Foundation
import FirebaseStorage

class UploadRecordfile : FirebaseStoreUpload {
    
    func uploadToFirebase(fileUrl: URL, fileName: String, totalTime : String) {
        let storageRef = Storage.storage().reference()
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "audio/m4a"
        uploadMetadata.customMetadata = ["totalTime" : "\(totalTime)"]
        do {
            let recordRef = storageRef.child("voiceRecords").child("\(fileName)")
            let audioData = try Data(contentsOf: fileUrl)
            let uploadTask = recordRef.putData(audioData, metadata: uploadMetadata) { data, error in
                if let error = error {
                    print("Error - UploadFail \(error)")
                    return
                }
            }
            
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error {
                    print("Error - UploadFail \(error)")
                }
            }
        } catch {
            print("Error - uploadToFirebase \(error)")
        }
    }
    
}
