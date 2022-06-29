//
//  RecordListViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import Foundation
import SwiftUI

class RecordListViewModel {
    private var cellData: [String] = []
    private let networkManager = RecordNetworkManager()
    
    func getCellData(_ indexPath: IndexPath) -> String {
        return cellData[indexPath.row]
    }
    
    func getCellTotalCount() -> Int {
        return cellData.count
    }
    
    func update(completion: (() -> ())? = nil) {
        networkManager.getRecordList { [weak self] data in
            guard let data = data else { return }
            self?.cellData = data
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
    
//    func didSelectedCell(_ indexPath: IndexPath, completion: @escaping (Data?) -> ()) {
//        let filename = cellData[indexPath.row]
//        networkManager.getRecordData(filename: filename) { data in
//            completion(data)
//        }
//    }
}
