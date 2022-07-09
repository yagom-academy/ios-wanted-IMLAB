//
//  AudioListViewModel.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/06.
//

import Foundation
import AVFoundation
import AVFAudio

class AudioListViewModel {
    
    private let repository = FirebaseRepository()
    private var soundEffect: AVAudioPlayer?
    let recordingViewModel: RecordingViewModel
    let audioInformation: Observable<[AudioInformation]> = Observable([])
    
    init(recordingViewModel: RecordingViewModel) {
        self.recordingViewModel = recordingViewModel
        recordingViewModel.delegate = self
    }
    
    func downloadAll(completion: @escaping () -> ()) {
        Task.init {
            let names = try await repository.fetchAll()
            
            var audioInformations: [AudioInformation] = []
            
            for name in names {
                let audio = try await mapper(from: name)
                audioInformations.append(audio)
            }
            audioInformation.value = audioInformations
            completion()
        }
    }
    
    func delete(name endpoint: String){
        Task.init {
            try await repository.delete(endpoint)
        }
    }
    
    private func mapper(from name: String) async throws -> AudioInformation {
        let data = try await repository.download(from: name)
        let fileURL = repository.putDataLocally(from: name)
        let duration = convertToDuration(from: data)
        
        let audioInformation = AudioInformation(
            name: name,
            data: data,
            fileURL: fileURL,
            duration: duration
        )
        
        return audioInformation
    }

    private func convertToDuration(from data: Data) -> TimeInterval {
        do {
            try soundEffect = AVAudioPlayer(data: data)
            guard let sound = soundEffect else {
                return .zero
            }
            return sound.duration
        } catch {
            print(error.localizedDescription)
        }
        return .zero
    }
}

extension AudioListViewModel: RecordingViewModelDelegate {
    func recordingUploaded(_ audioInformation: AudioInformation) {
        self.audioInformation.value.append(audioInformation)
    }
}
