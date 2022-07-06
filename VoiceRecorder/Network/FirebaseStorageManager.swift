//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/01.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    
    private var baseReference: StorageReference!
    private var dateUtil = DateUtil()
    
    init() {
        baseReference = Storage.storage().reference()
    }
    
    func uploadAudio(url: URL) {
        let title = dateUtil.formatDate()
        let filePath = "\(title).caf"
        let data = try! Data(contentsOf: url)
        let metaData = StorageMetadata()
        metaData.contentType = "audio/x-caf"
        
        baseReference.child(filePath).putData(data, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("성공")
            }
        }
    }
    
    func downloadAudio(from urlString: String, to localUrl: URL, completion: @escaping (URL?) -> Void) {
        baseReference.child(urlString).write(toFile: localUrl) { url, error in
            completion(url)
        }
    }
    
    func downloadAll() {
        baseReference.listAll { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let result = result {
                for item in result.items {
                    // item.reference로 파일 다운
                    print("item storage", item.storage)
                    print("item bucket", item.bucket)
                    print("item fullPath", item.fullPath)
                    print("item desc", item.description)
                    print("item name", item.name)
                    print("item hash", item.hash)
                    print("item", item)
                }
            }
        }
    }
    
    func downLoadMetaData() {
        baseReference.getMetadata { metaData, error in
            print(metaData?.name)
        }
    }
}
