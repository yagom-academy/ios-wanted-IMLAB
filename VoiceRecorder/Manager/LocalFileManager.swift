//
//  LocalFileManager.swift
//  VoiceRecorder
//
//

import Foundation

class LocalFileManager {
    private let fileManager = FileManager.default
    private lazy var filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    lazy var audioPath = filePath.appendingPathComponent(recordModel.name)
    private let network = Network()
    
    let recordModel: RecordModel
    init(recordModel: RecordModel) {
        self.recordModel = recordModel
    }
    
    func downloadToLocal(didFinish completion: @escaping (Error?) -> Void) {
        network.fetchData(url: recordModel.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    try data.write(to: self.audioPath)
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    func deleteToLocal() {
        guard (try? fileManager.removeItem(at: audioPath)) != nil else { return }
    }
}


