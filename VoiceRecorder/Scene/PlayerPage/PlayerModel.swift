//
//  PlayerModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerModel {
    private var data: AVAudioFile?
    private var fileData: FileData?
    
    let networkManager: NetworkManager!
    
    init(_ networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func update(_ filename: String, _ completion: @escaping (Error?) -> Void) {
        parsingFileData(filename)

        networkManager.getRecordData(filename: filename) { result in
            switch result {
            case let .success(data):
                self.data = data.getAVAudioFile()
                completion(nil)
            case let .failure(error):
                completion(error)
                break
            }
        }
    }

    private func parsingFileData(_ filename: String) {
        let file = filename.split(separator: "+").map { String($0) }

        if file.count == 2 {
            fileData = FileData(fileName: file[0], duration: file[1])
        }
    }

    func getFileData() -> FileData? {
        return fileData
    }

    func getAVAudioFile() -> AVAudioFile? {
        return data
    }
}
