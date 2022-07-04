//
//  WaveFormView.swift
//  VoiceRecorder
//
//  Created by jamescode on 2022/07/04.
//

import UIKit


enum WaveFormViewDataType {
    case all
    case live
}

class WaveFormView: UIView {
    
    // MARK: - Properties
    var waveFormViewDataType: WaveFormViewDataType = .live
    var caLayer: CAShapeLayer!
    var barWidth: CGFloat = 4.0
    var color = UIColor.gray.cgColor
    var waveforms = [Float]()
    var count = 0
    
    //활성화에 따른 바 색상 변경
    var active = false {
        didSet {
            if self.active {
                self.color = UIColor.red.cgColor
            }
            else {
                self.color = UIColor.gray.cgColor
            }
        }
    }
    
    // MARK: - init
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.clear
        caLayer = CAShapeLayer()
        caLayer.strokeColor = UIColor.red.cgColor
        caLayer.lineWidth = 1
        caLayer.cornerRadius = 0.5
        self.layer.addSublayer(caLayer)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public func shiftWaveform() {
        guard let sublayers = self.layer.sublayers else { return }
        for layer in sublayers {
            let transform  = CATransform3DTranslate(layer.transform, -5, 0, 0)
            layer.transform = transform
        }
    }
}
