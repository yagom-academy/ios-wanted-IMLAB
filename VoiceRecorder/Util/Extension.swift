//
//  UIViewExtension.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import UIKit
import AVFoundation

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

extension AVAudioFile{

    var duration: TimeInterval{
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }

}

extension AVAudioPlayerNode{

    var currentTime: TimeInterval{
        if let nodeTime = lastRenderTime,let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}

