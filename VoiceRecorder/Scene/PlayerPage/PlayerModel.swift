//
//  PlayerModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerModel {
    private var data: AVPlayerItem?
    private var fileData: FileData?

    func update(_ filename: String, _ completion: @escaping () -> Void) {
        let networkManager = RecordNetworkManager()

        parsingFileData(filename)

        networkManager.getRecordData(filename: filename) { data in
            // data 를 item 으로
            guard let data = data else {
                return
            }
            self.data = data.getAVPlayerItem()
            completion()
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

    func getAVPlayerItem() -> AVPlayerItem? {
        return data
    }
}
