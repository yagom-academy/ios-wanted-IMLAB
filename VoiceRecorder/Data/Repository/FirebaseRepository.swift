//
//  FirebaseRepository.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/06/30.
//

import Foundation
import FirebaseStorage

final class FirebaseRepository: AudioRepository {

    typealias AudioName = String
    typealias EndPoint = AudioName

    private var recordURL: URL {
        let documentsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }()
        let fileName = UUID().uuidString + Audio.format
        let url = documentsURL.appendingPathComponent(fileName)
        return url
    }

    func fetchAll() async throws -> [AudioName] {
        let audioReference = Storage.storage().reference()
        let storageListResult = try await audioReference.listAll()

        var audioNames: [AudioName] = []
        
        for storageReference in storageListResult.items {
            audioNames.append(storageReference.name)
        }

        return audioNames
    }

    func download(from endPoint: AudioName) async throws -> Data {
        let storageReference = Storage.storage().reference().child(endPoint)
        let data = try await storageReference.data(maxSize: Audio.megabyte)

        return data
    }

    func putDataLocally(from endPoint: AudioName) -> URL {
        let url = recordURL
        let storageReference = Storage.storage().reference().child(endPoint)
        storageReference.write(toFile: url)
        return url
    }

    func upload() {
        let metadata = StorageMetadata()
        metadata.contentType = Audio.contentType
        let audioReference = Storage.storage().reference().child("voiceRecords\(Date.now).\(Audio.format)")

        audioReference.putFile(from: recordURL, metadata: metadata)
    }

    func delete(_ endPoint: AudioName) async throws {
        let audioReference = Storage.storage().reference().child(endPoint)

        try await audioReference.delete()
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
