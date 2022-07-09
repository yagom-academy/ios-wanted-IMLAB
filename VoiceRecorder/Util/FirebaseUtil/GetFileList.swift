//
//  GetFileList.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/29.
//

import Foundation
import FirebaseStorage

class GetFileList : FirebaseStoreFileList {
    func getFirebaseStoreFileList(handler: @escaping (Result<[String], Error>) -> ()) {
        var filePaths = [String]()
        let storageReference = Storage.storage().reference().child("voiceRecords")
        storageReference.listAll { result, error in
            if let error = error {
                print("Error - Fail to get List \(error)")
                return
            }
            
            guard let datas = result else { return }
            
            for data in datas.items {
                filePaths.append(data.fullPath)
            }
            
            handler(.success(filePaths))
        }
    }
}
