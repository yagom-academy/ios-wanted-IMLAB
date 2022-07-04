//
//  PlayListUserDefaults.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import Foundation

class PlayListUserDefaults {
    private let userDefaults = UserDefaults(suiteName: "playList")
    
    func save(playList: [String]) {
        userDefaults?.setValue(playList, forKey: "playList")
    }
    
    func getData() -> [String] {
        guard let savedData = userDefaults?.object(forKey: "playList") as? [String] else { return [] }
        return savedData
    }
    
    func update(networkData: [String]) -> [String] {
        print("networkData: ", networkData)
        print("getdata: ", getData())
        let frontList = getData().filter { networkData.contains($0) }
        let backList = networkData.filter { frontList.contains($0) == false }

        let result = frontList + backList
        save(playList: result)
        return result
    }
}
