//
//  FirebaseStorageDownload.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import Foundation

class FirebaseStorageDownload {
    var downloadHandler : FirebaseStoreDownload
    
    init(_ firebaseStoreDownload : FirebaseStoreDownload) {
        self.downloadHandler = firebaseStoreDownload
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
}
