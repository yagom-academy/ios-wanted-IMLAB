//
//  RecordListViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewModel {
    private var playList: [String] = []
    private var networkManager: NetworkManager
    private let recordListUserDefaults = RecordListUserDefaults.shared

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getCellData(_ indexPath: IndexPath) -> FileData {
        let rawFileName = playList[indexPath.row].split(separator: "+").map { String($0) }
        let fileData = FileData(rawFilename: playList[indexPath.row],filename: rawFileName[0], duration: rawFileName[1])

        return fileData
    }

    func getCellTotalCount() -> Int {
        return playList.count
    }

    func update(completion: (() -> Void)? = nil) {
        networkManager.getRecordList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.playList = self.recordListUserDefaults.update(networkDataFilename: data)
                completion?()
            case let .failure(error):
                // TODO: 에러처리
                break
            }
        }
    }

    func deleteCell(_ indexPath: IndexPath, completion: @escaping () -> Void) {
        let filename = playList[indexPath.row]
        networkManager.deleteRecord(filename: filename) { isDeleted in
            if isDeleted == true {
                self.playList = self.playList.filter { $0 != filename }
                completion()
            } else {
            }
        }
    }

    func swapCell(_ beforeIndexPathRow: Int, _ indexPathRow: Int) {
        let beforeValue = playList[beforeIndexPathRow]
        let afterValue = playList[indexPathRow]
        playList[beforeIndexPathRow] = afterValue
        playList[indexPathRow] = beforeValue
    }

    func endTapped() {
        recordListUserDefaults.save(playList: playList)
    }
}
