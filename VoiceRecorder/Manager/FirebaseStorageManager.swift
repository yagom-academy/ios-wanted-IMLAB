//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/06/27.
//

import Foundation
import FirebaseCore
import FirebaseStorage

enum NetworkError: Error {
    case error
}

class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    private let storage = Storage.storage()
    private let storageReferenceStr = "voiceMemo/"
    
    private init() { }
    
    // Todo: customError 타입 만들기 ( NetworkError )
    func uploadVoiceMemoToFirebase(with voiceMemoURL: URL, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        print(#function)
        guard let voiceMemoData = try? Data(contentsOf: voiceMemoURL) else {
            completion(.failure(.error))
            return
        }
        let voiceMemoID = UUID().uuidString
        let reference = storage.reference().child("\(storageReferenceStr)\(voiceMemoID)")
        let metaData = StorageMetadata()
        metaData.contentType = "audio/mpeg"
        
        reference.putData(voiceMemoData, metadata: metaData) { result in
            switch result {
            case .success(_):
                completion(.success(voiceMemoID))
            case .failure(_) :
                completion(.failure(.error))
            }
        }
    }
    
    func fetchVoiceVoiceMemoAtFirebase(with id: String, completion: @escaping ((Result<Data, NetworkError>)-> Void)) {
        print(#function)
        let reference = storage.reference().child("\(storageReferenceStr)\(id)")
        reference.downloadURL { result in
            switch result {
            case .success(let url):
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url) else {
                        completion(.failure(.error))
                        return
                    }
                    completion(.success(data))
                }
            case .failure(_):
                completion(.failure(.error))
            }
        }
    }
    
    func removeVoiceMemoInFirebase(with id: String, completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        print(#function)
        let reference = storage.reference().child("\(storageReferenceStr)\(id)")
        
        reference.delete { error in
            guard error != nil else {
                completion(.failure(.error))
                return
            }
            completion(.success(true))
        }
    }
}
