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
        static var fileName = "recording"
        static let fileExtension = ".m4a"
        static var fileFullName = "recording\(fileName)\(fileExtension)"
        static let recording: String = "recording/"
    }
    
    var items: [StorageReference] = []
    let storage = Storage.storage()
    
    func uploadRecordDataToFirebase(_ url: URL?) {
        guard let url = url else {
            return
        }
        let storageRef = storage.reference()
        let riversRef = storageRef.child("recording/\(RecordFileString.fileName)")
        riversRef.putFile(from: url)
    }
    
    func getDataFromFirebase() -> [StorageReference] {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(RecordFileString.recording)
        fileRef.listAll() { (result, error) in
            if let error = error {
                print(error)
            }
            for item in result.items {
                self.items.append(item)
            }
        }
        print(items)
        return items
    }
}
