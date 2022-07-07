//
//  RecordListViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewModel {
    struct CellData {
        var fileInfo: FileData
        var isFavorite: Bool = false
    }
    private var recordDatas: [RecordListUserDefaults.DBData] = []
    private var networkManager: NetworkManager
    private let recordListUserDefaults = RecordListUserDefaults.shared
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getCellData(_ indexPath: IndexPath) -> CellData {
        let rawFileName = recordDatas[indexPath.row].fileName.split(separator: "+").map { String($0) }
        let fileData = FileData(rawFilename: recordDatas[indexPath.row].fileName,filename: rawFileName[0], duration: rawFileName[1])
        let result = CellData(fileInfo: fileData, isFavorite: recordDatas[indexPath.row].isFavorite)
        
        return result
    }

    func getCellTotalCount() -> Int {
        return recordDatas.count
    }

    func update(completion: (() -> Void)? = nil) {
        networkManager.getRecordList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.recordDatas = self.recordListUserDefaults.update(networkData: data)
                completion?()
            case let .failure(error):
                // TODO: 에러처리
                break
            }
        }
    }

    func deleteCell(_ indexPath: IndexPath, completion: @escaping () -> Void) {
        let filename = recordDatas[indexPath.row].fileName
        networkManager.deleteRecord(filename: filename) { isDeleted in
            if isDeleted == true {
                self.recordDatas = self.recordDatas.filter { $0.fileName != filename }
                completion()
            } else {
            }
        }
    }

    func swapCell(_ beforeIndexPathRow: Int, _ indexPathRow: Int) {
        let beforeValue = recordDatas[beforeIndexPathRow]
        let afterValue = recordDatas[indexPathRow]
        recordDatas[beforeIndexPathRow] = afterValue
        recordDatas[indexPathRow] = beforeValue
    }

    func endSwapCellTapped() {
        recordListUserDefaults.save(data: recordDatas)
    }
    
    func tappedFavoriteButton(indexPath: IndexPath) {
        recordDatas[indexPath.row].isFavorite = !recordDatas[indexPath.row].isFavorite
        recordListUserDefaults.save(data: recordDatas)
    }
}
