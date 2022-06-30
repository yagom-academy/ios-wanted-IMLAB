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
    private let storageReferenceStr = "VoiceMemo/"
    
    private init() { }
    
    // Todo: customError 타입 만들기 ( NetworkError )
    func uploadVoiceMemoToFirebase(with voiceMemoURL: URL, fileName: String, completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        print(#function)
        guard let voiceMemoData = try? Data(contentsOf: voiceMemoURL) else {
            completion(.failure(.error))
            return
        }
        
        let reference = storage.reference().child("\(storageReferenceStr)\(fileName)")
        let metaData = StorageMetadata()
        metaData.contentType = "audio/mpeg"
        
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
        print(#function)
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
        print(#function)
        let reference = storage.reference().child("\(fileName)")
        
        reference.delete { error in
            guard error != nil else {
                completion(.failure(.error))
                return
            }
            completion(.success(true))
        }
    }
    
    func listAll() {
        storageReference.listAll {
            (result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let result = result else {
                print("no result")
                return
            }
            
            for pre in result.prefixes {
                print("pre:", pre)
            }
            
            for item in result.items {
                print("item:", item)
                print(item.fullPath)
            }
        }
}
