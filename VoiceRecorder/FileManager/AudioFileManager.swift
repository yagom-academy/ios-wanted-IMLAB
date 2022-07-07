//
//  AudioFileManager.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

class AudioFileManager {
    
    private let fileManager = FileManager.default
    
    private let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recorded_Voice") // 메인 폴더
    
    init() {
        initalizeFileFolder()
    }
    
    private func initalizeFileFolder() {
        
        guard !fileManager.fileExists(atPath: directoryPath.path) else { return }
        createDic()
    }
    
    private func createDic() {
        do {
            try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false)
        } catch let erorr {
            print(erorr.localizedDescription)
        }
    }
    
    func getAudioFilePath(fileName: String) -> URL {
        return directoryPath.appendingPathComponent(fileName)
    }
}
