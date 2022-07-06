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
        
        restartWaveForm()
        self.layer.addSublayer(caLayer)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    // MARK: - Methods
    public func shiftWaveform() {
        guard let sublayers = self.layer.sublayers else { return }
        for layer in sublayers {
            let transform  = CATransform3DTranslate(layer.transform, -5, 0, 0)
            layer.transform = transform
        }
    }
    
    
    func restartWaveForm() {
        count = 0
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        caLayer = CAShapeLayer()
        caLayer.strokeColor = UIColor.red.cgColor
        caLayer.lineWidth = 1
        caLayer.cornerRadius = 0.5
        self.layer.addSublayer(caLayer)
    }
    
    override func draw(_ rect: CGRect) {
        if waveFormViewDataType == .live {
            liveDraw()
        } else {
            allDraw()
        }
        
    }
    
    private func allDraw() {
        count = 0
        
        let path: UIBezierPath!
        
        if let ppath = caLayer.path {
            path = UIBezierPath(cgPath: ppath)
        } else {
            path = UIBezierPath()
        }
        
        for wave in waveforms {
            count += 1
            
            var waveData = wave
            
            if (waveData <= 0) {
                waveData = 0.02
            }
            
            if (waveData > 1) {
                waveData = 1
            }
            
            let startX = self.bounds.origin.x + 1 * CGFloat(count)
            
            //waveForm뷰의 y축의 중간
            let startY = self.bounds.origin.y + self.bounds.height / 2

            //위로 이동하는 포인터
            path.move(to: CGPoint(x: startX, y: startY + CGFloat(waveData * Float(self.bounds.height) / 2)))
            
            //포인터를 아래로 잡아끄는 것
            path.addLine(to: CGPoint(x: startX, y: startY - CGFloat(waveData * Float(self.bounds.height) / 2)))
            
            caLayer.path = path.cgPath
        }
    }
    
    private func liveDraw() {
        shiftWaveform()
        count += 1
        
        let path: UIBezierPath!
        
        if let ppath = caLayer.path {
            path = UIBezierPath(cgPath: ppath)
        } else {
            path = UIBezierPath()
        }
        
        guard var wave = waveforms.last else { return }
        if (wave <= 0) {
            wave = 0.02
        }
        
        if (wave > 1) {
            wave = 1
        }
        
        let startX = self.bounds.width + 5 * CGFloat(count)
        let startY = self.bounds.origin.y + self.bounds.height / 2
        path.move(to: CGPoint(x: startX, y: startY + CGFloat(wave * 100)))
        path.addLine(to: CGPoint(x: startX, y: startY - CGFloat(wave * 100)))
        
        caLayer.path = path.cgPath
    }
}
