//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class RecordListUserDefaults {
    typealias DBData = [String]
    static let shared = RecordListUserDefaults()
    private init() { }

    private let userDefaults = UserDefaults(suiteName: "recordList")

    func save(playList: DBData) {
        self.userDefaults?.setValue(playList, forKey: "recordList")
    }
    
    func getData() -> DBData {
        guard let savedData = userDefaults?.object(forKey: "recordList") as? DBData else { return [] }
        return savedData
    }

    func update(networkDataFilename: DBData) -> DBData {
        let frontList = getData().filter { networkDataFilename.contains($0) }
        let backList = networkDataFilename.filter { frontList.contains($0) == false }

        let result = frontList + backList
        save(playList: result)
        return result
    }
}
