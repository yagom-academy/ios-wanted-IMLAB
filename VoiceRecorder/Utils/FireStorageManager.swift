//
//  FireStorageManager.swift
//  VoiceRecorder
//
//  Created by 조성빈 on 2022/06/29.
//

import Foundation
import FirebaseStorage

class FireStorageManager {
    static var shared = FireStorageManager()
    
    enum RecordFileString {
        enum Ref {
            static let recordDir: String = "recording/"
        }
        enum Path {
            static var fileName = ""
        }
        enum contentType {
            static let audio: String = ".m4a"
        }
        static let fileFullName: String = "recording\(Path.fileName)"
        
    }
    
    var items: [StorageReference] = []
    let storage = Storage.storage()
    
    func uploadData(_ url: URL?) {
        guard let url = url else {
            return
        }
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(RecordFileString.Ref.recordDir)\(RecordFileString.fileFullName)")
        fileRef.putFile(from: url)
    }
    
    func fetchData(completion: @escaping ([StorageReference]) -> Void )  {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(RecordFileString.Ref.recordDir)
        fileRef.listAll() { (result, error) in
            if let error = error {
                print(error)
            }
            for item in result.items {
                self.items.append(item)
            }
            completion(self.items)
            
        }
    }
    
    func deleteItem(_ name : String) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(RecordFileString.Ref.recordDir)\(name)")

        // Delete the file
        fileRef.delete { error in
          if let error = error {
            print(error)
          } else {
            // File deleted successfully
          }
        }
    }
}
