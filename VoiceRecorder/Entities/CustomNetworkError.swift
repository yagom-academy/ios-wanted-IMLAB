//
//  CustomNetworkError.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/04.
//

import Foundation

enum CustomNetworkError: Error {
    case failLoadData
    case noData
    
    var description: String {
        switch self {
        case .failLoadData:
            return "데이터 로드에 실패했습니다."
        case .noData:
            return "유효한 데이터가 없습니다."
        }
    }
}
