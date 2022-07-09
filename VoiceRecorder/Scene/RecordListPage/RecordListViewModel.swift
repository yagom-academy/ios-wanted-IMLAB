//
//  RecordListViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewModel {
    private var recordDatas: [CellData] = []
    private var networkManager: NetworkManager
    private let recordListUserDefaults = RecordListUserDefaults.shared
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getCellData(_ indexPath: IndexPath) -> CellData? {
        guard indexPath.row < recordDatas.count else {
            return nil
        }
        return recordDatas[indexPath.row]
    }

    func getCellTotalCount() -> Int {
        return recordDatas.count
    }

    func update(completion: ((Result<Void,CustomNetworkError>) -> Void)? = nil) {
        networkManager.getRecordList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                let parsingData: [CellData] = data.map { data in
                    let rawFileName = data.split(separator: "+").map { String($0) }
                    let fileData = FileData(rawFilename: data,filename: rawFileName[0], duration: rawFileName[1])
                    let result = CellData(fileInfo: fileData)
                    return result
                }
                self.recordDatas = self.recordListUserDefaults.update(networkData: parsingData)
                completion?(.success(Void()))
            case let .failure(error):
                // TODO: 에러처리
                completion?(.failure(error))
                break
            }
        }
    }

    func deleteCell(_ indexPath: IndexPath, completion: @escaping () -> Void) {
        let filename = recordDatas[indexPath.row].fileInfo.rawFilename
        networkManager.deleteRecord(filename: filename) { isDeleted in
            if isDeleted == true {
                self.recordDatas = self.recordDatas.filter { $0.fileInfo.rawFilename != filename }
                completion()
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
        recordListUserDefaults.updateFavoriteState(fileInfo: recordDatas[indexPath.row].fileInfo)
    }
    
    func sortButtonTapped(beforeState: RecordListSortState, afterState: RecordListSortState, completion: @escaping () -> ()) {
        self.recordDatas = recordListUserDefaults.getData()
        switch afterState {
        case .basic:
            completion()
        case .latest:
            recordDatas.sort(by: sortLatest(a:b:))
            completion()
        case .oldest:
            recordDatas.sort(by: sortOldest(a:b:))
            completion()
        case .favorite:
            recordDatas = recordDatas.filter { $0.isFavorite }
            completion()
        }
        
        func sortLatest(a: CellData, b: CellData) -> Bool {
            return a.fileInfo.filename > b.fileInfo.filename
        }
        
        func sortOldest(a: CellData, b: CellData) -> Bool {
            return a.fileInfo.filename < b.fileInfo.filename
        }
    }
}
