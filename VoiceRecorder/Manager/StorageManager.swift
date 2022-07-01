//
//  StorageManager.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/28.
//

import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()
    
    private init() {}
    
    func upload(data: Data, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/\(fileName).m4a")
        
        recordRef.putData(data) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
            return
        }
    }
    
    func get(completion: @escaping (Result<RecordModel, Error>) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/")
        recordRef.listAll { result, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let result = result {
                result.items.forEach { item in
                    item.downloadURL { url, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        if let url = url {
                            let recordModel = RecordModel(name: item.name, url: url)
                            completion(.success(recordModel))
                            return
                        }
                    }
                }
            }
        }
    }
    
    func delete(fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference()
        let desertRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/\(fileName)")
        
        desertRef.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                completion(.success(()))
                return
            }
        }
    }
}
