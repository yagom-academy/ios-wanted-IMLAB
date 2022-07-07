//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import Foundation

class HomeViewModel {
    // TODO: - Combine
    // TODO: - View Indicator 추가
    var audios: [Audio]
    var loadingEnded: () -> Void = { }
    
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
                print(error.localizedDescription)
            }
            
            self.audios.sort { $0.title < $1.title }
            self.loadingEnded()
        }
    }
    
    func deleteAudio(_ indexPath: IndexPath) {
        let deleteItemName = audios[indexPath.row].fileName
        FirebaseStorageManager.shared.deleteData(title: deleteItemName)
        audios.remove(at: indexPath.row)
    }
}
