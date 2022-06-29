//
//  StorageManager.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/28.
//

import Foundation
import FirebaseStorage

struct StorageManager {
    private let storage = Storage.storage()
    
    func upload(data: Data, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("record/\(fileName).m4a")
        
        recordRef.putData(data) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
            return
        }
    }
    
    func get(completion: @escaping (Result<[String], Error>) -> Void) {
        let storageRef = storage.reference()
        let recordRef = storageRef.child("record/")
        recordRef.listAll { result, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let result = result {
                let names = result.items.map { $0.name }
                let datas = result.items.map { item in item.getData(maxSize: Int64.max) { result in
                    switch result {
                    case .success(let data):
                        let recordModel = RecordModel(name: item.name, data: data)
                    case .failure(let error):
                        print("error")
                    }
                }}
                completion(.success(names))
            }
        }
    }
    
    func delete(fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference()
        let desertRef = storageRef.child("record/\(fileName)")
        
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
