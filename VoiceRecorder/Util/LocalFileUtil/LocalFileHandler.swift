//
//  LocalFileHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

struct LocalFileHandler : LocalFileProtocol {
    
    var localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func getFileCreatedDate(file: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) -> Date {
        var fileCreationDate = Date()
        do {
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any]
            fileCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
        } catch let error {
            print("file not found \(error)")
        }
        return fileCreationDate
    }
    
    func getFileName() -> String {
        let date = self.getFileCreatedDate(file: localFileURL)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let fileName = formatter.string(from: date as Date)
        return "voiceRecords_\(fileName).m4a"
    }

}
