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
    
    let recordModel: RecordModel
    init(recordModel: RecordModel) {
        self.recordModel = recordModel
    }
    
    func downloadToLocal() {
        do {
            let data = try Data(contentsOf: recordModel.url)
            try data.write(to: audioPath)
        } catch {
            print("다운로드 에러")
        }
    }
    func deleteToLocal() {
        
        do {
            try fileManager.removeItem(at: audioPath)
        } catch {
            print(error)
        }
    }
}
