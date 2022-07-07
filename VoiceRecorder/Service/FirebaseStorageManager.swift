//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private let folderName = "voiceRecords"
    private lazy var storage = Storage.storage().reference().child(folderName)
    private let deviceID: String?
    
    private init() {
        self.deviceID = UIDevice.current.identifierForVendor?.uuidString
    }
    
    func fetch(completion: @escaping (Result<Audio?, Error>) -> Void) {
        guard let deviceID = deviceID else {
            return
        }
        
        storage.child(deviceID).listAll { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            if result.items.isEmpty {
                completion(.success(nil))
            }
            
            result.items.forEach { item in
                self.itemDownloadURL(item) { audio in
                    completion(.success(audio))
                }
            }
        }
    }
    
    func itemDownloadURL(_ item: StorageReference, completion: @escaping (Audio) -> Void) {
        let title = "\(self.folderName)_" + item.name.replacingOccurrences(of: ".m4a", with: "")
        item.downloadURL { url, error in
            guard let url = url, error == nil else {
                return
            }
            
            let audio = Audio(title: title, url: url, fileName: item.name)
            completion(audio)
        }
    }
    
    func uploadData(url: URL, fileName: String) {
        if let deviceID = deviceID {
            storage.child("\(deviceID)/\(fileName)").putFile(from: url)
        }
    }
    
    func deleteData(title: String) {
        if let deviceID = deviceID {
            storage.child("\(deviceID)/\(title)").delete { error in
                guard let error = error else {
                    return
                }
                print(error.localizedDescription)
            }
        }
    }
}
