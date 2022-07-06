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
    
    private let storage = Storage.storage()
    private let storageReferenceStr = "VoiceRecoder/"
    
    init() { }
    
    // Todo: customError 타입 만들기 ( NetworkError )
    func uploadVoiceMemoToFirebase(with voiceMemoURL: URL, fileName: String, playTime:String, completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        guard let voiceMemoData = try? Data(contentsOf: voiceMemoURL) else {
            completion(.failure(.error))
            return
        }
        
        let reference = storage.reference().child("\(storageReferenceStr)\(fileName)")
        let metaData = StorageMetadata()
        metaData.contentType = "audio/mpeg"
        metaData.customMetadata = ["playTime":playTime]
        
        reference.putData(voiceMemoData, metadata: metaData) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(_) :
                completion(.failure(.error))
            }
        }
    }
    
    func fetchVoiceMemoAtFirebase(with fileName: String, localPath: URL, completion: @escaping ((Result<Bool, NetworkError>)-> Void)) {
        
        let islandReference = storage.reference().child("\(storageReferenceStr)\(fileName)")
        let localPathURL = localPath
        
        islandReference.write(toFile: localPathURL) { url, error in
            guard error == nil else {
                completion(.failure(.error))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func removeVoiceMemoInFirebase(with fileName: String, completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let reference = storage.reference().child("\(storageReferenceStr)\(fileName)")
        
        reference.delete { error in
            guard error != nil else {
                completion(.failure(.error))
                return
            }
            completion(.success(true))
        }
    }
    
    func listAll(completion: @escaping ((Result<[String], NetworkError>) -> Void)) {
        let reference = storage.reference().child(storageReferenceStr)
        reference.listAll {
            (result, error) in
            guard let result = result,
                  error == nil else {
                completion(.failure(.error))
                return
            }
            let items = result.items.map { $0.fullPath }
            completion(.success(items))
        }
    }
    
    func getMetaData(fileName: String, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        let reference = storage.reference().child("\(fileName)")
        reference.getMetadata {
            (result, error) in
            guard error == nil else {
                completion(.failure(.error))
                return
            }
            guard let result = result,
                  let metaData = result.customMetadata?["playTime"]
            else {
                completion(.failure(.error))
                return
            }
            completion(.success(metaData))
        }
    }
}
