//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/01.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    
    private var baseReference: StorageReference!
    private let soundManager = SoundManager()
    private let audioFileManager = AudioFileManager()
    
    init() {
        baseReference = Storage.storage().reference()
    }
    
    func uploadAudio(url: URL, date: String) {
        let title = date
        let filePath = "\(title).caf"
        let data = try! Data(contentsOf: url)
        
        let metaData = StorageMetadata()
        let totalTime = soundManager.totalPlayTime(date: filePath)
        let duration = soundManager.convertTimeToString(totalTime)
        let customData = [
            "title": title,
            "duration": duration
        ]
        metaData.customMetadata = customData
        metaData.contentType = "audio/x-caf"
        
        baseReference.child(filePath).putData(data, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("upload success")
            }
        }
    }
    
    func downloadAudio(_ urlString: String, to localUrl: URL, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global().async {
            self.baseReference.child(urlString).write(toFile: localUrl) { url, error in
                completion(url)
            }
        }
        
    }
    
    func deleteAudio(urlString: String) {
        // cloud delete
        baseReference.child(urlString).delete { error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("delete success")
            }
        }
        
        // local delete
        let item = self.audioFileManager.getAudioFilePath(fileName: urlString)
        try? FileManager.default.removeItem(at: item)
    }
    
    func downloadAll(completion: @escaping (Result<AudioData, Error>) -> Void) {
        baseReference.listAll { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let result = result {
                for item in result.items {
                    self.downloadMetaData(filePath: item.name) { result in
                        switch result {
                        case .success(let audioData) :
                            completion(.success(audioData))
                        case .failure(let error) :
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    func downloadMetaData(filePath: String, completion: @escaping (Result<AudioData, Error>) -> Void) {
        let ref = baseReference.child(filePath)
        
        ref.getMetadata { metaData, error in
            if let error = error {
                completion(.failure(error))
            }
            
            let data = metaData?.customMetadata
            
            // 파일 이름 메타데이터가 없을 경우 파일 url을 잘라서 이름 양식에 맞춰 리턴
            let fileName = String(filePath.split(separator: "/").last ?? "")
            let splitExtension = String(fileName.split(separator: ".").first ?? "")
            
            let title = data?["title"] ?? String(splitExtension)
            let duration = data?["duration"] ?? "00:00"
            
            completion(.success(AudioData(title: title, duration: duration)))
        }
    }
    
}