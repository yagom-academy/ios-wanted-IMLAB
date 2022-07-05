//
//  HomeViewModel.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation

final class HomeViewModel {
    
    var audioTitles: [String] = []
    var audioData: [String: Observable<AudioRepresentation>] = [:]
    
    subscript(_ indexPath: IndexPath) -> AudioRepresentation? {
        let title = audioTitles[indexPath.item]
        guard let data = audioData[title]?.value else {return nil}
        return data
    }
    
    func fetchAudioTitles(completion: @escaping () -> Void) {
        FirebaseService.fetchAll { [weak self] result in
            switch result {
            case .success(let data):
                data.items.forEach({
                    self?.audioTitles.append($0.name)
                    self?.audioData.updateValue(Observable<AudioRepresentation>(AudioRepresentation(filename: nil, createdDate: nil, length: nil)), forKey: $0.name)
                })
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchMetaData(){
        audioTitles.forEach({
            let endPoint = EndPoint(fileName: $0)
            FirebaseService.featchMetaData(endPoint: endPoint) {[weak self] result in
                switch result {
                case .success(let metadata):
//                    self?.sortByDate()
                    self?.audioData[endPoint.fileName]?.value = metadata.toDomain()
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
    
    
    
    
    func enquireForURL() {
        audioTitles.forEach({
            let endPoint = EndPoint(fileName: $0)
            FirebaseService.makeURL(endPoint: endPoint) {[weak self] result in
                switch result {
                case .success(let url):
                    print(url)
                    //                   self?.audioURLs?.updateValue(Observable<URL>(url), forKey: endPoint.fileName)
                case .failure(let error):
                    print(error)
                }
            }
        })
        
    }
    
    func remove(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let title = audioTitles[indexPath.item]
        let audioInfo = AudioInfo(id: title, data: nil, metadata: nil)
        FirebaseService.delete(audio: audioInfo) { [weak self] error in
            if var error = error as? NSError {
                print(error)
                completion(false)
            }else{
                self?.audioTitles.remove(at: indexPath.item)
                self?.audioData.removeValue(forKey: title)
                completion(true)
            }
        }
    }
    
    
    
    
    func sortByDate() {
        self.audioTitles = audioTitles.sorted(by:{
            audioData[$0]?.value.createdDate?.compare(audioData[$1]?.value.createdDate ?? Date()) == .orderedAscending})
        
        self.audioTitles.forEach({
            guard let index = self.audioTitles.firstIndex(of: $0) else {return}
            guard let previousValue = self.audioData[self.audioTitles[index]] else {return}
            self.audioData[$0]?.value = previousValue.value
        })
        
    }

    
    
    
    
    
    func reset(){
        audioTitles.removeAll()
        audioData.removeAll()
    }
    
}
