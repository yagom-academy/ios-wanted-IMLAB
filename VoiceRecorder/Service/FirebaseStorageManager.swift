//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private let storage = Storage.storage().reference().child("voiceRecords")
    
    private init() { }
    
    func fetch(completion: @escaping (Result<Audio, Error>) -> Void) {
        storage.listAll { result, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let result = result {
                result.items.forEach { item in
                    item.downloadURL { url, error in
                        if let url = url {
                            item.getMetadata { metaData, error in
                                if let metaData = metaData {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
                                    let dateString = dateFormatter.string(from: metaData.timeCreated ?? Date())
                                    
                                    let titleString = "\(self.storage.name)_\(dateString)"
                                    let audio = Audio(title: titleString, url: url)
                                    completion(.success(audio))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadData(url:URL,fileName:String){
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else{return}
        storage.child("\(deviceId)/\(fileName)").putFile(from: url)
    }
}
