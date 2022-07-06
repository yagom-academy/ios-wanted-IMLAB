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
    private let deviceId: String?
    
    private init() {
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString
    }
    
    func fetch(completion: @escaping (Result<Audio, Error>) -> Void) {
        guard let deviceId = deviceId else {
            return
        }

        storage.child(deviceId).listAll { result in
            switch result {
            case .success(let result):
                result.items.forEach { item in
                    let title = "\(self.folderName)_" + item.name.replacingOccurrences(of: ".m4a", with: "")
                    item.downloadURL { result in
                        switch result {
                        case .success(let url):
                            let audio = Audio(title: title, url: url, fileName: item.name)
                            print(audio.title, audio.fileName)
                            completion(.success(audio))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
        
    func uploadData(url: URL, fileName: String) {
        if let deviceId = deviceId {
            storage.child("\(deviceId)/\(fileName)").putFile(from: url)
        }
    }
    
    func deleteData(title: String) {
        if let deviceId = deviceId {
            storage.child("\(deviceId)/\(title)").delete { err in
                guard let err = err else {
                    return
                }
                print(err.localizedDescription)
            }
        }
    }
}
