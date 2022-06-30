//
//  FirebaseUseCase.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/30.
//

import Foundation

protocol Downloadable {
    
    func downloadURL() async throws -> [AudioURL]
    func downloadData(from url: URL) async throws -> Data
}

protocol Uploadable {
    
    func upload() async throws -> URL
}

protocol Deletable {
    
    func delete(from url: URL) async throws
}

protocol FirebaseUseCaseType: Downloadable, Uploadable, Deletable { }

final class FirebaseUseCase: FirebaseUseCaseType {
    
    let repository: FirebaseRepository
    
    init(repository: FirebaseRepository) {
        self.repository = repository
    }
    
    func downloadURL() async throws -> [AudioURL] {
        let audioURLs = try await repository.downloadURL()
        
        return audioURLs
    }
    
    func downloadData(from url: URL) async throws -> Data {
        let data = try await repository.downloadData(from: url)
        
        return data
    }
    
    func upload() async throws -> URL {
        let url = try await repository.upload()
        
        return url
    }
    
    func delete(from url: URL) async throws {
        _ = try await repository.delete(from: url)
    }
}
