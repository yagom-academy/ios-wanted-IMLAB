//
//  FirebaseStorageUpload.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import Foundation

class FirebaseStorageUpload {
    
    var uploadHandler : FirebaseStoreUpload
    
    init(_ firebaseStoreUpload : FirebaseStoreUpload) {
        self.uploadHandler = firebaseStoreUpload
    }
    
    func uploadFile(fileUrl: URL,fileName: String,totalTime: String) {
        uploadHandler.uploadToFirebase(fileUrl: fileUrl, fileName: fileName,totalTime: totalTime)
    }
}
