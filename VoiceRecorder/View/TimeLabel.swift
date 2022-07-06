//
//  TimeLabel.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/06.
//

import UIKit

class TimeLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        self.adjustsFontForContentSizeCategory = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
