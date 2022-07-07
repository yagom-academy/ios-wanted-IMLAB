//
//  PlayerViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerViewModel {
    private let model = PlayerModel(RecordNetworkManager.shared)
    private var audioPlayer: PlayerService!

    var pitchViewModel: PitchViewModel!
    var speedViewModel: SpeedViewModel!
    var volumeViewModel: VolumeViewModel!
    var playerButtonViewModel: PlayerButtonViewModel!

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer

        pitchViewModel = PitchViewModel(audioPlayer)
        speedViewModel = SpeedViewModel(audioPlayer)
        volumeViewModel = VolumeViewModel(audioPlayer)
        playerButtonViewModel = PlayerButtonViewModel(audioPlayer)
    }

    func update(_ filename: String, _ completion: @escaping (Error?) -> Void) {
        model.update(filename) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
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
        return model.getFileData()
    }

    func setPlayerItem() {
        audioPlayer.setAudioFile(model.getAVAudioFile())
    }

    func setPlayerToZero() {
        audioPlayer.setPlayerToZero()
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
