//
//  LocalFileHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

struct LocalFileHandler : LocalFileProtocol {
    
    var localFileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    
    func makeFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let fileName = formatter.string(from: Date())
        return "voiceRecords_\(fileName)"
    }
    
    func getLatestFileName() -> String {
        let path = localFileURL.path
        var latestFileName = ""
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: path).sorted(by: <)
            let latestFile = list.last ?? "파일이 존재하지 않습니다"
            latestFileName = latestFile
        } catch let error {
            print("Error - getLatestFileName \(error)")
        }
        return latestFileName
    }
    
    func checkFileExists(fileName : String) -> Bool {
        let filePath = localFileURL.appendingPathComponent("voiceRecords_\(fileName)").path
        let fileManger  = FileManager.default
        
        if fileManger.fileExists(atPath: "\(filePath)") {
            print("FILE AVAILABLE")
            return true
        } else {
            print("FILE PATH NOT AVAILABLE")
            return false
        }
    }
}
