//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class RecordListUserDefaults {
    struct DBData: Codable {
        var fileName: String
        var isFavorite: Bool = false
        
        func isContain(data: [DBData]) -> Bool {
            let dataFileNames = data.map { $0.fileName }
            return dataFileNames.contains(fileName)
        }
    }
    
    static let shared = RecordListUserDefaults()
    private init() { }
    
    private let userDefaults = UserDefaults(suiteName: "recordData")

    func save(data: [DBData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            self.userDefaults?.setValue(encoded, forKey: "recordData")
        }
    }
    
    func getData() -> [DBData] {
        if let savedData = userDefaults?.object(forKey: "recordData") as? Data {
            let decoder = JSONDecoder()
            let savedObject = try? decoder.decode([DBData].self, from: savedData)
            return savedObject ?? []
        }
        return []
    }

    func update(networkData: [String]) -> [DBData] {
        let newDBData = networkData.map { DBData(fileName: $0) }
        let frontList = getData().filter { $0.isContain(data: newDBData) }
        let backList = newDBData.filter { $0.isContain(data: frontList) == false }

        let result = frontList + backList
        save(data: result)
        return result
    }
}
