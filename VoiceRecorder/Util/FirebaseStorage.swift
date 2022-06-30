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
    var getFileList : FirebaseStoreFileList
    
    init(_ firebaseStoreUpload : FirebaseStoreUpload,_ firebaseStoreDownload : FirebaseStoreDownload, _ firebaseStoreDelete : FirebaseStoreDelete,_ GetfirebaseStoreFileList : FirebaseStoreFileList) {
        self.uploadHandler = firebaseStoreUpload
        self.downloadHandler = firebaseStoreDownload
        self.deleteHandler = firebaseStoreDelete
        self.getFileList = GetfirebaseStoreFileList
    }
    
    func uploadFile(fileUrl:URL,fileName:String) {
        uploadHandler.uploadToFirebase(fileUrl: fileUrl, fileName: fileName)
    }
    
    func downloadFile(fileName:String, hander : @escaping (Result<String, Error>) -> ()) {
        downloadHandler.downloadFromFirebase(fileName: fileName) { result in
            switch result {
            case .success(let fileUrl) :
                hander(.success(fileUrl))
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    func deleteFile(fileName:String) {
        deleteHandler.deleteOnTheFirebase(fileName: fileName)
    }
    
    func getFileLset() -> [String] {
        return getFileList.getFirebaseStoreFileList()
    }
}

