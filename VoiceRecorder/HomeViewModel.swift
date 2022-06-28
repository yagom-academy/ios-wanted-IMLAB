//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import Foundation

class HomeViewModel {
    private(set) var audios: [Audio]
    var loadingEnded: () -> Void = { }
    
    init() {
        self.audios = []
    }
    
    func audiosCount() -> Int {
        return self.audios.count
    }
    
    func audio(at index: Int) -> Audio {
        return self.audios[index]
    }
    
    func fetch() {
        FirebaseStorageManager.shared.fetch { result in
            switch result {
            case .success(let audio):
                self.audios.append(audio)
                self.loadingEnded()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
