//
//  FirebaseRepositoryInterface.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import Foundation

protocol FirebaseRepository {
    
    func upload() async throws -> URL
    func downloadURL() async throws -> [AudioURL]
    func downloadData(from url: URL) async throws -> Data
    func delete(from url: URL) async throws
}
