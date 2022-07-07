//
//  YagomColor.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation
import UIKit

enum YagomColor {
    case one
    case two
    case three
    var uiColor: UIColor {
        switch self {
        case .one:
//            return .init(red: 155/256, green: 119/256, blue: 108/256, alpha: 1)
            return .init(red: 242/256, green: 205/256, blue: 174/256, alpha: 1)
        case .two:
//            return .init(red: 109/256, green: 75/256, blue: 65/256, alpha: 1)
            return .init(red: 115/256, green: 87/256, blue: 77/256, alpha: 1)
        case .three:
//            return .init(red: 75/256, green: 43/256, blue: 32/256, alpha: 1)
            return .init(red: 64/256, green: 52/256, blue: 44/256, alpha: 1)
        }
    }
}
