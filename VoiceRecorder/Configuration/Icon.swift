//
//  Icon.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/28.
//

import UIKit

enum Icon {
    case circle
    case circleFill
    case play
    case pauseFill
    case delete
    
    var image: UIImage? {
        switch self {
        case .circle:
            return UIImage(systemName: "circle")
        case .circleFill:
            return UIImage(systemName: "circle.fill")
        case .play:
            return UIImage(systemName: "play")
        case .pauseFill:
            return UIImage(systemName: "pause.fill")
        case .delete:
            return UIImage(systemName: "trash.fill")
        }
    }
}
