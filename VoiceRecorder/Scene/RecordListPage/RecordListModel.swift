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
    
    func swapByPress(with sender: UILongPressGestureRecognizer, to tableView: UITableView) {
        let p = sender.location(in: tableView)

        guard let indexPath = tableView.indexPathForRow(at: p) else {
            print("fail to find indexPath!")
            playListUserDefaults.save(playList: cellData)
            return
        }
        
        struct BeforeIndexPath {
            static var value: IndexPath?
        }
        
        switch sender.state {
        case .began:
            BeforeIndexPath.value = indexPath
        case .changed:
            if let beforeIndexPath = BeforeIndexPath.value, beforeIndexPath != indexPath {
                let beforeValue = cellData[beforeIndexPath.row]
                let afterValue = cellData[indexPath.row]
                cellData[beforeIndexPath.row] = afterValue
                cellData[indexPath.row] = beforeValue
                tableView.moveRow(at: beforeIndexPath, to: indexPath)
                
                BeforeIndexPath.value = indexPath
            }
        case .ended:
            playListUserDefaults.save(playList: cellData)
        default:
            // TODO: animation
            break
        }
    }
}
