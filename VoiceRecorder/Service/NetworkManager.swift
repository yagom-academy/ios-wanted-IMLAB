//
//  NetworkManager.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/06.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    func downloadAudioAndMove(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentURL.appendingPathComponent("Record.m4a")
        
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            guard let localUrl = localUrl, error == nil else {
                //TODO: - Error 처리 하기
                return
            }
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.moveItem(at: localUrl, to: fileURL)
                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}
