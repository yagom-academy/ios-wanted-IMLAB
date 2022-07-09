//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import Foundation
import Combine

final class HomeViewModel {
    @Published var audios: [Audio]
    
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
        audios.removeAll()
        
        FirebaseStorageManager.shared.fetch { result in
            switch result {
            case .success(let audio):
                self.audios.append(audio)
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
            
            self.audios.sort { $0.title < $1.title }
        }
    }
    
    func deleteAudio(_ indexPath: IndexPath) {
        let deleteItemName = audios[indexPath.row].fileName
        FirebaseStorageManager.shared.deleteData(fileName: deleteItemName) {
            self.audios.remove(at: indexPath.row)
        }
    }
}
