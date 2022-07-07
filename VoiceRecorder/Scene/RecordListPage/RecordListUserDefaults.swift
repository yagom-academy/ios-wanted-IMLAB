//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class RecordListUserDefaults {
    struct DBData {
        var fileName: String
        var isFavorite: Bool = false
        
        func isContain(data: [DBData]) -> Bool {
            let dataFileNames = data.map { $0.fileName }
            return dataFileNames.contains(fileName)
        }
    }

    static let shared = RecordListUserDefaults()
    private init() { }

    private let userDefaults = UserDefaults(suiteName: "recordList")

    func save(playList: [DBData]) {
        self.userDefaults?.setValue(playList, forKey: "recordList")
    }
    
    func getData() -> [DBData] {
        guard let savedData = userDefaults?.object(forKey: "recordList") as? [DBData] else { return [] }
        return savedData
    }

    func update(networkData: [DBData]) -> [DBData] {
        let frontList = getData().filter { $0.isContain(data: networkData) }
        let backList = networkData.filter { $0.isContain(data: frontList) == false }

        let result = frontList + backList
        save(playList: result)
        return result
    }
}
