//
//  FirebaseStorageGetFileList.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import Foundation

class FirebaseStorageGetFileList {
    var getFileList : FirebaseStoreFileList
    
    init(_ getfirebaseStoreFileList : FirebaseStoreFileList) {
        self.getFileList = getfirebaseStoreFileList
    }
    
    func getFileList(handler : @escaping (Result<[String], Error>) -> ()) {
        getFileList.getFirebaseStoreFileList { result in
            switch result {
            case .success(let filePaths) :
                handler(.success(filePaths))
            case .failure(let error) :
                print("Error - getFileList \(error)")
            }
        }
    }
}
