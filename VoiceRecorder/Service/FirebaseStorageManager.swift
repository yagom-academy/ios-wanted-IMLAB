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
        let title = "\(self.folderName)_" + item.name.replacingOccurrences(of: ".m4a", with: "")
        item.downloadURL { url, error in
            guard let url = url, error == nil else {
                return
            }
             
            let audio = Audio(title: title, url: url, fileName: item.name)
            completion(audio)
        }
    }
    
    func uploadData(url: URL, fileName: String, completion: @escaping () -> Void) {
        guard let deviceID = deviceID else {
            return
        }
        
        storage.child("\(deviceID)/\(fileName)").putFile(from: url) { result in
            switch result {
            case .success(_):
                print("upload success")
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func uploadDataSet(data: Data, fileName:String) {
        guard let deviceID = deviceID else {
            return
        }
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"
        storage.child(deviceID).child(fileName)
            .putData(data,metadata: meta) { meta, error in
                guard error == nil else { return }
                print(meta?.name)
            }
    }
    
    func deleteData(title: String) {
        guard let deviceID = deviceID else {
            return
        }
        
        storage.child("\(deviceID)/\(title)").delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
            print("delete success")
        }
    }
}
