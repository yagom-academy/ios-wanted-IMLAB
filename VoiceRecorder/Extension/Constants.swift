//
//  Constants.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/07.
//

import Foundation

struct Constants {
    struct TableViewCellIdentifier {
        static let home = String(describing: HomeTableViewCell.self)
    }
    
    struct Alert {
        static let cancel = "취소"
        static let ok = "확인"
        static let empty = ""
        static let error = "오류 발생"
    }
    
    struct Firebase {
        static let foloderName = "voiceRecords"
        static let fileType = ".mp4"
    }
    
    struct ButtonSize {
        static let regular = 32.0
    }
    
    struct VolumeSliderSize {
        static let half: Float = 0.5
    }
}
