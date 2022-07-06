//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class PlayListUserDefaults {
    typealias DBData = [String]
    static let shared = PlayListUserDefaults()
    private init() { }
    
    private let userDefaults = UserDefaults(suiteName: "playList")
    
    func save(playList: DBData) {
        self.userDefaults?.setValue(playList, forKey: "playList")
    }
    
    func getData() -> DBData {
        guard let savedData = userDefaults?.object(forKey: "playList") as? DBData else { return [] }
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
