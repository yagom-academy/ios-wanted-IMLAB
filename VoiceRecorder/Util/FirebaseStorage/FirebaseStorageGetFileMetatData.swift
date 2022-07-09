//
//  FirebaseStorageGetFileMetatData.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import Foundation

class FirebaseStorageGetFileMetatData {
    var getFileMetatData : FirebaseStoreFileMetaData
    
    init(_ getfirebaseStoreMetaData : FirebaseStoreFileMetaData) {
        self.getFileMetatData = getfirebaseStoreMetaData
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
