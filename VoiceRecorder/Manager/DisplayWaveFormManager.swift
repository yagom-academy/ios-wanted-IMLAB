//
//  DisplayWaveFormManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/04.
//

import UIKit

@objc protocol DisplayWaveFormDelegate : AnyObject {
    @objc func updateWaveForm(in view : UIImageView)
}

enum WaveFormStatus {
    case normal, forward, backward
}

enum PlayStatus {
    case start, pause, finish
}


class DisplayWaveFormManager{

    weak var delegate : DisplayWaveFormDelegate!
    private var displayLink : CADisplayLink?
    private var step : CGFloat!
    private var totalStep : CGFloat!
    private var waveFormStatus : WaveFormStatus!
    
    init() {
        totalStep = 0
        waveFormStatus = .normal
        displayLink = CADisplayLink(target: self, selector: #selector(delegate.updateWaveForm(in:)))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }

    func displayWaveForm(in view : UIImageView, when status: PlayStatus) {
        switch status {
        case .start:
            step = view.bounds.width/112
            displayLink?.isPaused = false
        case .pause:
            displayLink?.isPaused = true
        default:
            displayLink?.isPaused = true
            totalStep = 0
        }
    }

    func jumpFiveSecondsTotalStep(_ isForward: Bool) {
        if isForward {
            waveFormStatus = .forward
        } else {
            waveFormStatus = .backward
        }
    }

    func getTotalStep() -> CGFloat {
        return totalStep
    }

    func setTotalStep() {
        let jump = step * 70
        
        switch waveFormStatus {
        case .forward:
            totalStep -= jump
        case .backward:
            totalStep += jump
        default:
            totalStep += step
        }
    }

}
