//
//  FireStorageManager.swift
//  VoiceRecorder
//
//  Created by 조성빈 on 2022/06/29.
//

import Foundation
import FirebaseStorage

class FireStorageManager {
    
    // MARK: - Enums
    
    enum File {
        enum Ref {
            static let recordDir: String = "recording/"
            static let imageDir: String = "image/"
        }
        enum Path {
            static var fileName = ""
        }
        enum contentType {
            static let audio: String = ".m4a"
            static let image: String = ".jpeg"
        }
        static var fileFullName: String {
            return ("recording\(Path.fileName)")
        }
    }
    
    // MARK: - Properties
    
    static var shared = FireStorageManager()
    
    let storage = Storage.storage()
    
    // MARK: - Methods
    
    func uploadImage(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageRef = storageRef.child("\(File.Ref.imageDir)\(File.fileFullName)")
        guard let data = image.jpegData(compressionQuality: 1.0) else {return}
        imageRef.putData(data, metadata: metadata)
    }
    
    func downloadImage(_ name : String?, completion: @escaping (UIImage?) -> Void) {
        guard let name = name else {
            return
        }
        let storageRef = storage.reference()
        let imageRef = storageRef.child("image/\(name)")
        
        print(imageRef)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error: <downloadImage> - \(error.localizedDescription)")
            } else if let data = data {
                completion(UIImage(data: data))
            }
        }
    }
    
    func uploadData(_ url: URL?) {
        guard let url = url else {
            return
        }
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
        metadata.contentType = "audio/x-m4a"
        let fileRef = storageRef.child("\(File.Ref.recordDir)\(File.fileFullName)")
        fileRef.putFile(from: url, metadata: metadata)
    }
    
    func fetchData(completion: @escaping ([URL]) -> Void ) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(File.Ref.recordDir)
        fileRef.listAll() { (result, error) in
            if let error = error {
                print("Error: <FireStorageManager fetchData> - \(error.localizedDescription)")
            }
            self.downloadToLocal(urls: result.items) { localUrls in
                completion(localUrls)
            }
        }
    }
    
    func downloadToLocal(urls: [StorageReference]
                         ,completion: @escaping ([URL]) -> Void
    ) {
        var items: [String] = []
        let stringUri: [String] = urls.map { "\($0)" }
        if stringUri.isEmpty == true {
            completion([])
        } else {
            for uri in stringUri {
                let storageRef = self.storage.reference(forURL: uri)
                // 긴 uri 에서 "recording_2022_06_30_20:12:51" 끝 부분만 가져오기 위함
                let findIndex = uri.index(uri.endIndex, offsetBy: -29)
                let fileName = "\(uri[findIndex...]).m4a"
                guard let localPath = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )
                    .first?.appendingPathComponent(fileName) else { return }
                
                storageRef.write(toFile: localPath) { url, error in
                    if let url = url {
                        items.append(url.absoluteString)
                    }
                    let sortedItems = items.sorted()
                    let itemsToURL = sortedItems.compactMap { URL(string: $0) }
                    completion(itemsToURL)
                }
            }
        }
    }
    
    func deleteRecording(_ name : String) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(File.Ref.recordDir)\(name)")
        fileRef.delete()
    }
    
    func deleteImage(_ name : String) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(File.Ref.imageDir)\(name)")
        fileRef.delete()
    }
}
