//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import Foundation
import Combine

class HomeViewModel {
    @Published var audios: [Audio]
    @Published var isReady = false
    
    init() {
        audios = []
    }
    
    func audiosCount() -> Int {
        return audios.count
    }
    
    func audio(at index: Int) -> Audio {
        return audios[index]
    }
    
    func fetch() {
        isReady = false
        audios.removeAll()
        
        FirebaseStorageManager.shared.fetch { result in
            switch result {
            case .success(let audio):
                guard let audio = audio else {
                    self.isReady = true
                    return
                }
                self.audios.append(audio)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            self.audios.sort { $0.title < $1.title }
            self.isReady = true
        }
    }
    
    func deleteAudio(_ indexPath: IndexPath) {
        let deleteItemName = audios[indexPath.row].fileName
        FirebaseStorageManager.shared.deleteData(title: deleteItemName)
        audios.remove(at: indexPath.row)
    }
}
