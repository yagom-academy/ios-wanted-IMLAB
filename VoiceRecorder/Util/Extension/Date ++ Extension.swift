//
//  Date ++ Extension.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/09.
//

import Foundation

extension Date {
    
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
