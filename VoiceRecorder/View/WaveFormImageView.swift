//
//  WaveFormImageView.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/06.
//

import UIKit

class WaveFormImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.width = CGFloat(FP_INFINITE)
        self.contentMode = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
