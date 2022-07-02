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
        static var fileFullName: String {
            return ("recording\(Path.fileName)")
        }
    }
    
    var items: [URL] = []
    let storage = Storage.storage()
    
    func uploadData(_ url: URL?) {
        guard let url = url else {
            return
        }
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
        metadata.contentType = "audio/x-m4a"
        let fileRef = storageRef.child("\(RecordFileString.Ref.recordDir)\(RecordFileString.fileFullName)")
        fileRef.putFile(from: url, metadata: metadata)
    }
    
    func fetchData(completion: @escaping ([URL]) -> Void )  {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(RecordFileString.Ref.recordDir)
        fileRef.listAll() { (result, error) in
            if let error = error {
                print(error)
            }
            self.downloadToLocal(uris: result.items) { localUrls in
                completion(localUrls)
            }
            
        }
    }
    
    // escaping 클로저로 data 넘기기
    func downloadToLocal(uris: [StorageReference]
                         ,completion: @escaping ([URL]) -> Void
    ) {
        let stringUri: [String] = uris.map { "\($0)" }
            for uri in stringUri {
                let storageRef = storage.reference(forURL: uri)
                // 긴 uri 에서 "recording_2022_06_30_20:12:51" 끝 부분만 가져오기 위함
                let findIndex = uri.index(uri.endIndex, offsetBy: -29)
                let fileName = "\(uri[findIndex...]).m4a"
                guard let localPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else { return }
                storageRef.write(toFile: localPath)
                items.append(localPath)
            }
        completion(items)
        
    }
    
    func deleteItem(_ name : String) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(RecordFileString.Ref.recordDir)\(name)")
        
        fileRef.delete()
    }
}
