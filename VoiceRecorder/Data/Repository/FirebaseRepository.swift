//
//  FirebaseRepository.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/06/30.
//

import Foundation
import FirebaseStorage

final class FirebaseRepository: FirebaseRepositoryInterface {
    
    private lazy var recordURL: URL = {
        var documentsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }()
        let fileName = UUID().uuidString + Audio.format
        let url = documentsURL.appendingPathComponent(fileName)
        return url
    }()
    
    func upload() async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = Audio.contentType
        let audioReference = Storage.storage().reference().child("\(Date.now)\(Audio.format)")

        audioReference.putFile(from: recordURL, metadata: metadata)
        let url = try await audioReference.downloadURL()
        
        return url
    }
    
    func downloadURL() async throws -> [AudioURL] {
        let audioReference = Storage.storage().reference()
        let storageListResult = try await audioReference.listAll()
        
        var audioURLs: [AudioURL] = []
        
        for storageReference in storageListResult.items {
            let fileName = storageReference.name
            let url = try await storageReference.downloadURL()
            let audioURL = AudioURL(name: fileName, url: url)
            audioURLs.append(audioURL)
        }
        
        return audioURLs
    }
    
    func downloadData(from url: URL) async throws -> Data {
        let audioReference = Storage.storage().reference(forURL: url.absoluteString)
        
        let data = try await audioReference.data(maxSize: Audio.megabyte)
        return data
    }
    
    func delete(from url: URL) async throws {
        let audioReference = Storage.storage().reference(forURL: url.absoluteString)
        
        _ = try await audioReference.delete()
    }
}

// MARK: - NameSpaces

extension FirebaseRepository {

    private enum Audio {
        
        static let contentType: String = "audio/m4a"
        static let format: String = ".m4a"
        static let megabyte: Int64 = Int64(1 * 1024 * 1024)
    }
}
