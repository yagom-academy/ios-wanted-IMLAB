//
//  AudioFileManager.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

enum FileError: String {
    case canNotDeleteFile = "파일을 지울 수 없습니다."
    case fileDoesNotExit = "경로에 해당 파일이 존재하지 않습니다."
}

protocol FileStatusReceivable {
    func fileManager(_ fileManager: FileManager, error: FileError)
}

class AudioFileManager {
    
    var delegate: FileStatusReceivable!
    private let fileManager = FileManager.default
    private let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recorded_Voice")
    
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
    
    func deleteLocalAudioFile(fileName: String) {
        let filePath = directoryPath.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.removeItem(at: filePath)
            } catch {
                delegate.fileManager(fileManager, error: FileError.canNotDeleteFile)
            }
        } else {
            delegate.fileManager(fileManager, error: FileError.fileDoesNotExit)
        }
    }
}
