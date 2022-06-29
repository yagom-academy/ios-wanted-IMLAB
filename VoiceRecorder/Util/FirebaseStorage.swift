//
//  FirebaseStorage.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/27.
//

import Foundation
import FirebaseStorage

class FirebaseStorage {
    
    var uploadHandler : FirebaseStoreUpload
    var downloadHandler : FirebaseStoreDownload
    var deleteHandler : FirebaseStoreDelete
    
    init(firebaseStoreUpload : FirebaseStoreUpload, firebaseStoreDownload : FirebaseStoreDownload, firebaseStoreDelete : FirebaseStoreDelete) {
        self.uploadHandler = firebaseStoreUpload
        self.downloadHandler = firebaseStoreDownload
        self.deleteHandler = firebaseStoreDelete
    }
    
    func uploadFile(fileUrl:URL,fileName:String) {
        uploadHandler.uploadToFirebase(fileUrl: fileUrl, fileName: fileName)
    }
    
    func downloadFile(fileUrl:URL,fileName:String) {
        downloadHandler.downloadFromFirebase(fileUrl: fileUrl, fileName: fileName)
    }
    
    func deleteFile(fileName:String) {
        deleteHandler.deleteOnTheFirebase(fileName: fileName)
    }
}

