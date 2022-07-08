//
//  UIButtonExtensions.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/08.
//

import UIKit

extension UIButton {
    func makePlaySeekButton(_ image: UIImage?) -> UIButton {
        self.setImage(image, for: .normal)
        self.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: Constants.ButtonSize.regular), forImageIn: .normal)
        self.isEnabled = false
        return self
    }
}
