//
//  AudioFileManager.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/02.
//

import Foundation

class AudioFileManager {
    
    private let fileManager = FileManager.default
    
    private let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init() {
        initalizeFileFolder()
    }
    
    func initalizeFileFolder() {
        let directoryPath: URL = docPath.appendingPathComponent("Recorded_Voice")
        createDic(url: directoryPath)
    }
    
    func createDic(url: URL) {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
        } catch let erorr {
            print(erorr.localizedDescription)
        }
    }
    
    func createVoiceFile(fileName: String) { // fileName date로 들어옴
        let textPath: URL = docPath.appendingPathComponent(fileName)
        
        if let data: Data = "TEST txt.".data(using:String.Encoding.utf8) {
            
            do {
                try data.write(to: textPath)
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    func getVoiceFile(fileName: String) {
        
        let textPath: URL = docPath.appendingPathComponent(fileName)
        do {
            let dataFromPath: Data = try Data(contentsOf: textPath) // URL을 불러와서 Data타입으로 초기화
            let text: String = String(data: dataFromPath, encoding: .utf8) ?? "문서없음" // Data to String
            print(text) // 출력
        } catch let e {
            print(e.localizedDescription)
        }
    }
}
