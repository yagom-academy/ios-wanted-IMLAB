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
    private let folderName = Constants.Firebase.foloderName
    private lazy var storage = Storage.storage().reference().child(folderName)
    private let deviceID: String?
    
    private init() {
        self.deviceID = UIDevice.current.identifierForVendor?.uuidString
    }
    
    func fetch(completion: @escaping (Result<Audio, Error>) -> Void) {
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
            
            result.items.forEach { item in
                self.itemDownloadURL(item) { audio in
                    completion(.success(audio))
                }
            }
        }
    }
    
    private func itemDownloadURL(_ item: StorageReference, completion: @escaping (Audio) -> Void) {
        let title = "\(self.folderName)_" + item.name.replacingOccurrences(of: Constants.Firebase.fileType, with: "")
        item.downloadURL { url, error in
            guard let url = url, error == nil else {
                return
            }
            
            let audio = Audio(title: title, url: url, fileName: item.name)
            completion(audio)
        }
    }
    
    func uploadDataSet(data: Data, fileName: String, completion: @escaping () -> Void) {
        guard let deviceID = deviceID else {
            return
        }
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"
        storage.child(deviceID).child(fileName)
            .putData(data,metadata: meta) { meta, error in
                guard error == nil else { return }
                completion()
            }
    }
    
    func deleteData(fileName: String, completion: @escaping () -> Void) {
        guard let deviceID = deviceID else {
            return
        }
        
        storage.child("\(deviceID)/\(fileName)").delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    func replaceData(previousFileName: String, data: Data, fileName: String, completion: @escaping () -> Void) {
        uploadDataSet(data: data, fileName: fileName) {
            self.deleteData(fileName: previousFileName) {
                completion()
            }
        }
    }
}
