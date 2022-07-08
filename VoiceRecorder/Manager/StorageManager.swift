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
        newMetaData: [String: String],
        completion: @escaping (Result<Void, Error>
        ) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/\(fileName).m4a")
        
        let metaData = StorageMetadata()
        metaData.customMetadata = newMetaData
        
        recordRef.putData(data, metadata: metaData) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
            return
        }
    }
    
    func get(completion: @escaping (Result<[RecordModel], Error>) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("\(StoragePath.voiceRecords.rawValue)/")
        recordRef.listAll { result, error in
            if let error = error {
                completion(.failure(error))
            }
            if let result = result {
                if result.items.isEmpty {
                    completion(.success([]))
                    return
                }
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
                                   let customMetaData = meta.customMetadata {
                                    
                                    let recordModel = RecordModel(
                                        name: item.name,
                                        url: url,
                                        metaData: customMetaData
                                    )
                                    completion(.success([recordModel]))
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
    
    func decibelUpload(_ decibels: [Int], completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = storage.reference()
        let decibelRef = storageRef.child("Decibel/\(UUID().uuidString)")
        
        let data = JSONEncoder.encode(decibels)
        
        decibelRef.putData(data) { _, error in
            if let error = error {
                print(error, "🐻")
                completion(.failure(error))
                return
            }
            decibelRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let url = url {
                    completion(.success(url))
                    return
                }
            }
            return
        }
    }
}
