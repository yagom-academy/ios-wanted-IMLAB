//
//  RecordListViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewModel {
    private let model = RecordListModel()
    
    func getCellData(_ indexPath: IndexPath) -> String {
        return model.getCellData(indexPath)
    }
    
    func getCellTotalCount() -> Int {
        return model.getCellTotalCount()
    }
    
    func update(completion: (() -> ())? = nil) {
        model.update(completion: completion)
    }
    
    func deleteCell(_ indexPath: IndexPath, completion: @escaping () -> ()) {
        model.deleteCell(indexPath, completion: completion)
    }
    
//    func swapByPress(with sender: UILongPressGestureRecognizer, to tableView: UITableView) {
//        model.swapByPress(with: sender, to: tableView)
//    }
    
    func swapCell(_ beforeIndexPathRow: Int, _ indexPathRow: Int) {
        model.swapCell(beforeIndexPathRow, indexPathRow)
    }
    
    func failToFindIndexPath() {
        print("fail to find indexPath!")
        model.saveListToUserDefaults()
    }
    
    func endTapped() {
        model.saveListToUserDefaults()
    }
}
