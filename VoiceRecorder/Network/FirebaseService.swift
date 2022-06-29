//
//  Services.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation

import FirebaseStorage

enum FirebaseService {
    
    static func fetchAll(completion: @escaping (Result <[StorageReference], Error>) -> Void) {
        
        EndPoint.reference.listAll { result, error in
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }
            guard let result = result else {return}
            completion(.success(result.items))
            return
        }
        
    }
    
    static func makeURL(fileName: String, completion: @escaping (Result <URL, Error>) -> Void)  {
        
        let endPoint = EndPoint(fileName: fileName)
       
        endPoint.path.downloadURL{ url, error in
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }
            guard let url = url else {return}
            completion(.success(url))
            return
        }
    }
    
    
    static func uploadAudio(fileName: String, data: Data, completion: @escaping (Error?) -> Void) {
       
        let endPoint = EndPoint(fileName: fileName)
        
        endPoint.path.putData(data) { storageMetadata, error in
            if let error = error as? NSError {
                completion(error)
                return
            }
            guard storageMetadata != nil else {return}
            completion(nil)
            return
        }
    }
    
    static func delete(fileName: String, completion: @escaping (Error?) -> Void) {
        
        let endPoint = EndPoint(fileName: fileName)
        
        endPoint.path.delete { error in
            if let error = error as? NSError {
                completion(error)
                return
            }else{
                completion(nil)
                return
            }
        }
    }
}
