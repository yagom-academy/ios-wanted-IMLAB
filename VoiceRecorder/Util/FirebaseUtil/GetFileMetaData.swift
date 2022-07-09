//
//  GetFileMetaData.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/30.
//

import Foundation
import FirebaseStorage

class GetFileMetaData : FirebaseStoreFileMetaData {
    func getFirebaseStoreFileMetaData(fileName: String, handler: @escaping (Result<String, Error>) -> ()) {
        let storageReference = Storage.storage().reference().child("\(fileName)")
        storageReference.getMetadata { metadata, error in
            if let error = error {
                print("Error - Fail to get metadata \(error)")
            }
            guard let totalTime = metadata?.customMetadata?["totalTime"] else { handler(.success("00:00")); return }
            handler(.success(totalTime))
        }
        
    }
    
    
}
