//
//  FirebaseStorage.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/27.
//

import Foundation
import FirebaseStorage

class FirebaseStorage {
    
    static let shared = FirebaseStorage(UploadRecordfile(), DownloadRecordfile(), DeleteRecordfile(), GetFileList(), GetFileMetaData())
    
    var uploadHandler : FirebaseStoreUpload
    var downloadHandler : FirebaseStoreDownload
    var deleteHandler : FirebaseStoreDelete
    var getFileList : FirebaseStoreFileList
    var getFileMetatData : FirebaseStoreFileMetaData
    
    private init(_ firebaseStoreUpload : FirebaseStoreUpload,_ firebaseStoreDownload : FirebaseStoreDownload, _ firebaseStoreDelete : FirebaseStoreDelete,_ GetfirebaseStoreFileList : FirebaseStoreFileList,_ GetfirebaseStoreMetaData : FirebaseStoreFileMetaData) {
        self.uploadHandler = firebaseStoreUpload
        self.downloadHandler = firebaseStoreDownload
        self.deleteHandler = firebaseStoreDelete
        self.getFileList = GetfirebaseStoreFileList
        self.getFileMetatData = GetfirebaseStoreMetaData
    }
    
    func uploadFile(fileUrl: URL,fileName: String,totalTime: String) {
        uploadHandler.uploadToFirebase(fileUrl: fileUrl, fileName: fileName,totalTime: totalTime)
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
    
    func getFileList(handler : @escaping (Result<[String], Error>) -> ()) {
        getFileList.getFirebaseStoreFileList { result in
            switch result {
            case .success(let filePaths) :
                handler(.success(filePaths))
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    func getFileMetaData(fileName: String, handler : @escaping (Result<String, Error>) -> ()) {
        getFileMetatData.getFirebaseStoreFileMetaData(fileName: fileName) { result in
            switch result {
            case .success(let totalTime) :
                handler(.success(totalTime))
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
}

