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
        static var fileName = ""
        static let fileExtension = ".m4a"
        static var fileFullName = "recording\(fileName)\(fileExtension)"
        static let recordingDirectory: String = "recording/"
    }
    
    var items: [StorageReference] = []
    let storage = Storage.storage()
    
    func uploadRecordDataToFirebase(_ url: URL?) {
        guard let url = url else {
            return
        }
        let storageRef = storage.reference()
        let riversRef = storageRef.child("\(RecordFileString.recordingDirectory)\(RecordFileString.fileName)")
        riversRef.putFile(from: url)
    }
    
    func getDataFromFirebase(completion: @escaping ([StorageReference]) -> Void )  {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(RecordFileString.recordingDirectory)
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
}
