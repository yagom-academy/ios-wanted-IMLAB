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
    private let dateUtil = DateUtil()
    private let soundManager = SoundManager()
    
    var audioLength: String = ""
    var audioTitle: String = ""
    
    init() {
        baseReference = Storage.storage().reference()
    }
    
    func uploadAudio(url: URL) {
        let title = dateUtil.formatDate()
        let filePath = "\(title).caf"
        let data = try! Data(contentsOf: url)
        
        let metaData = StorageMetadata()
        let customData = [
            "title": title,
            "length": String(Int(soundManager.totalPlayTime()))
        ]
        metaData.customMetadata = customData
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
        baseReference.listAll { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let result = result {
                for item in result.items {
                    // item.reference로 파일 다운
                    self.downloadMetaData(filePath: item.name)
                }
            }
        }
    }
    
    func downloadMetaData(filePath: String) {
        let ref = baseReference.child(filePath)
        var length: String = ""
        var title: String = ""
        
        ref.getMetadata { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            let data = metaData?.customMetadata
            length =  data?["length"] ?? "00:00"
            title = data?["title"] ?? "no title"
        }
        
        audioLength = length
        audioTitle = title
    }
}
