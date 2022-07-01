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
        var tempList: [String] = []
        FirebaseService.fetchAll { [weak self] result in
            switch result {
            case .success(let data):
                data.items.forEach({
                    tempList.append($0.name)
                    self?.audioData.updateValue(Observable<AudioRepresentation>(AudioRepresentation(filename: nil, createdDate: nil, length: nil)), forKey: $0.name)
                })
                completion()
                self?.audioTitles = tempList
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
//                    self?.audioURLs?.updateValue(Observable<URL>(url), forKey: endPoint.fileName)
                case .failure(let error):
                    print(error)
                }
            }
        })
        
    }
    
    
    
}

