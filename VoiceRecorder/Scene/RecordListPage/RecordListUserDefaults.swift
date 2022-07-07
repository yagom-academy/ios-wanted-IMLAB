//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class RecordListUserDefaults {
    static let shared = RecordListUserDefaults()
    private init() { }
    
    private let userDefaults = UserDefaults(suiteName: "recordData")

    func save(data: [CellData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            self.userDefaults?.setValue(encoded, forKey: "recordData")
        }
    }
    
    func getData() -> [CellData] {
        if let savedData = userDefaults?.object(forKey: "recordData") as? Data {
            let decoder = JSONDecoder()
            let savedObject = try? decoder.decode([CellData].self, from: savedData)
            return savedObject ?? []
        }
        return []
    }

    func update(networkData: [CellData]) -> [CellData] {
        let frontList = getData().filter { $0.isContain(data: networkData) }
        let backList = networkData.filter { $0.isContain(data: frontList) == false }

        let result = frontList + backList
        save(data: result)
        return result
    }
}
