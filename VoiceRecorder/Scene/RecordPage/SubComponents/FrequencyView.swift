//
//  FrequencyView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class FrequencyView: UIView {
    private var barWidth: CGFloat = 4.0
    private var color = ThemeColor.blue600.cgColor

    private var waveForms = [Int](repeating: 0, count: 100) {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self, selector: #selector(sendWaveformNotification(_:)), name: Notification.Name("SendWaveform"), object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }

    // MARK: - Notification Selector function

    @objc func sendWaveformNotification(_ notification: Notification) {
        guard let wave = notification.object as? [Int] else { return }
        waveForms = wave
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SendWaveform"), object: nil)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        var bar: CGFloat = 0

        context.clear(rect)
        context.setFillColor(ThemeColor.blue100.cgColor)
        context.fill(rect)
        context.setLineWidth(3)
        context.setStrokeColor(color)

        let centerY: CGFloat = frame.height / 2

        for i in 0 ..< waveForms.count {
            let firstX = bar * barWidth
            let firstY = centerY + CGFloat(waveForms[i])
            let secondY = centerY - CGFloat(waveForms[i])

            context.move(to: CGPoint(x: firstX, y: centerY))
            context.addLine(to: CGPoint(x: firstX, y: firstY))
            context.move(to: CGPoint(x: firstX, y: centerY))
            context.addLine(to: CGPoint(x: firstX, y: secondY))
            context.strokePath()

            bar += 1
        }
    }
}
