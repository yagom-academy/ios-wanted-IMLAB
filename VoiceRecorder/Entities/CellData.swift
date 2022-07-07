//
//  CellData.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation

struct CellData: Codable {
    var fileInfo: FileData
    var isFavorite: Bool = false
    
    func isContain(data: [CellData]) -> Bool {
        let dataFileNames = data.map { $0.fileInfo.rawFilename }
        return dataFileNames.contains(fileInfo.rawFilename)
    }
}
