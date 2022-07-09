//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class RecordListUserDefaults {
    private let SUITENAME:String = "recordData"
    static let shared = RecordListUserDefaults()
    private var cache:[CellData] = []
    private let userDefaults:UserDefaults?
    
    private init() {
        userDefaults = UserDefaults(suiteName: SUITENAME)
    }

    func save(data: [CellData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            self.userDefaults?.setValue(encoded, forKey: SUITENAME)
        }
    }
    
    func getData() -> [CellData] {
        if let savedData = userDefaults?.object(forKey: SUITENAME) as? Data {
            let decoder = JSONDecoder()
            let savedObject = try? decoder.decode([CellData].self, from: savedData)
            cache = savedObject ?? []
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
    
    func updateFavoriteState(fileInfo: FileData) {
        for i in 0..<cache.count {
            if (cache[i].fileInfo.rawFilename == fileInfo.rawFilename) {
                cache[i].isFavorite = !cache[i].isFavorite
                break
            }
        }
        save(data: cache)
    }
}
