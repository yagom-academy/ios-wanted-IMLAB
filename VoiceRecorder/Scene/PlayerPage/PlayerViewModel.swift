//
//  PlayerViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerViewModel {
    private var data: AVAudioFile?
    private var fileData: FileData?
    let networkManager: NetworkManager!
    
    private var audioPlayer: PlayerService!

    var pitchViewModel: PitchViewModel!
    var volumeViewModel: VolumeViewModel!
    var playerButtonViewModel: PlayerButtonViewModel!

    init(_ audioPlayer: PlayerService, _ networkManager: NetworkManager) {
        self.audioPlayer = audioPlayer
        self.networkManager = networkManager

        pitchViewModel = PitchViewModel(audioPlayer)
        volumeViewModel = VolumeViewModel(audioPlayer)
        playerButtonViewModel = PlayerButtonViewModel(audioPlayer)
    }

    func update(_ fileData: FileData, _ completion: @escaping (Error?) -> Void) {
        networkManager.getRecordData(filename: fileData.rawFilename) { result in
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
    
    func waveData(_ filename: String, _ completion: @escaping ([Int]?) -> Void ) {
        RecordNetworkManager.shared.getRecordMetaData(filename: filename) { metadata in
            guard let metadata = metadata, let wavesDict = metadata.customMetadata else {
                completion(nil)
                return
            }

            var waves = [Int]()

            for (key, val) in wavesDict.sorted { Int($0.key)! < Int($1.key)! } {
                waves.append(Int(val)!)
            }

            completion(waves)
        }
    }

    func getFileData() -> FileData? {
        return fileData
    }

    func setPlayerItem() {
        audioPlayer.setAudioFile(data)
    }

    func setPlayerToZero() {
        audioPlayer.setPlayerToZero()
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
