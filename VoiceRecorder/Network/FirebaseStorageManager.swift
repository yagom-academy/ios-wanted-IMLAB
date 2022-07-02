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
    
    private var baseUrl: URL?
    
    init(_ url: String) {
        self.baseUrl = URL(string: url)!
    }
    
    func getAllFileList() {
        let storageReference = Storage.storage().reference(forURL: "gs://voicerecorder-d6222.appspot.com")
        storageReference.listAll { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let result = result {
                for item in result.items {
                    // item.reference로 파일 다운
                    print(item)
                }
            }
        }
        
    }
    
    func download(urlString: String, completion: @escaping (Data?) -> Void) { // 싱글톤 유무
        
        
        
        
        let a = Storage.storage().reference(forURL: "gs://voicerecorder-d6222.appspot.com/").downloadURL { url, error in
            
            let data = try! Data(contentsOf: url!)
            completion(data)
        }
        
    }
    
    
    func uploadAudioFile() {
        
         
        let localFile = URL(string: "path/to/image")!
        
        
        // Create a reference to the file you want to upload
        let riversRef = Storage.storage().reference(forURL: "gs://voicerecorder-d6222.appspot.com/").child("images/rivers.jpg")
      
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }
    
    
}
