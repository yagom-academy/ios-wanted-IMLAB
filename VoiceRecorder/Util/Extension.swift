//
//  UIViewExtension.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import UIKit

// MARK: - 녹음 버튼 깜빡임 효과용
extension UIView {
    func controlFlashAnimate(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, alpha: CGFloat = 1.0, recordingMode: Bool) {
        self.alpha = 0.2
        if recordingMode {
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .allowUserInteraction], animations: {
                self.alpha = alpha
            })
        } else {
            self.alpha = 1.0
            self.layer.removeAllAnimations()
        }
    }
}
