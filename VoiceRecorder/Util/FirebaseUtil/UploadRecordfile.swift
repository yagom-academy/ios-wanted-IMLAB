//
//  UploadRecordfile.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/28.
//

import Foundation
import FirebaseStorage

class UploadRecordfile : FirebaseStoreUpload {
    
    func uploadToFirebase(fileUrl: URL, fileName: String) {
        let storageRef = Storage.storage().reference()
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "audio/m4a"
        do {
            let recordRef = storageRef.child("voiceRecords").child("\(fileName).m4a")
            let audioData = try Data(contentsOf: fileUrl)
            let uploadTask = recordRef.putData(audioData, metadata: uploadMetadata) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
            
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error {
                    print("Uplaod-Fail",error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
