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
    
    func upload(
        data: Data,
        fileName: String,
        duration: Double,
        completion: @escaping (Result<Void, Error>
        ) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/\(fileName).m4a")
        
        let metaData = StorageMetadata()
        metaData.customMetadata = ["duration": duration.toString.dropLast(3).description]
        
        recordRef.putData(data, metadata: metaData) { _, error in
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
                            
                            item.getMetadata { meta, error in
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                }
                                if let meta = meta,
                                   let duration = meta.customMetadata?["duration"] {
                                    
                                    let recordModel = RecordModel(name: item.name, url: url, duration: duration)
                                    completion(.success(recordModel))
                                    return
                                }
                            }
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
