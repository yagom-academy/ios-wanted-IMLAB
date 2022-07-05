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
        networkManager.getRecordList { [weak self] result in
            switch result {
            case .success(let data):
                self?.cellData = self?.playListUserDefaults.update(networkData: data) ?? []
                completion?()
            case .failure(let error):
                //TODO: 에러처리
                break;
            }
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
