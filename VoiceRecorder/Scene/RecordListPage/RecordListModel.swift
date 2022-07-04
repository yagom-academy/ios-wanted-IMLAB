//
//  RecordListModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/02.
//

import UIKit

class RecordListModel {
    private var cellData: [String] = []
    private let networkManager = RecordNetworkManager()
    private let playListUserDefaults = PlayListUserDefaults()
    
    func getCellData(_ indexPath: IndexPath) -> String {
        return cellData[indexPath.row]
    }
    
    func getCellTotalCount() -> Int {
        return cellData.count
    }
    
    func update(completion: (() -> ())? = nil) {
        networkManager.getRecordList { [weak self] data in
            guard let data = data else { return }
            self?.cellData = self?.playListUserDefaults.update(networkData: data) ?? []
            completion?()
        }
    }
    
    func deleteCell(_ indexPath: IndexPath, completion: @escaping () -> ()) {
        let filename = cellData[indexPath.row]
        networkManager.deleteRecord(filename: filename) { isDeleted in
            if (isDeleted == true) {
                self.cellData = self.cellData.filter { $0 != filename }
                    completion()
            } else {
                
            }
        }
    }
    
    func swapCell(_ beforeIndexPathRow: Int, _ indexPathRow: Int) {
        let beforeValue = cellData[beforeIndexPathRow]
        let afterValue = cellData[indexPathRow]
        cellData[beforeIndexPathRow] = afterValue
        cellData[indexPathRow] = beforeValue
    }
    
    func saveListToUserDefaults() {
        playListUserDefaults.save(playList: cellData)
    }
}
