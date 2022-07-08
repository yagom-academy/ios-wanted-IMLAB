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
        self.font = UIFont.monospacedDigitSystemFont(ofSize: CNS.size.time, weight: .light)
        self.adjustsFontForContentSizeCategory = true
        self.text = "00:00:00"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ time : TimeInterval) {
        self.text = time.getStringTimeInterval()
    }
}
