//
//  UIButton+.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/05.
//

import UIKit

extension UIButton {
    func setImage(_ icon: Icon) {
        self.setImage(icon.image, for: .normal)
    }
}
