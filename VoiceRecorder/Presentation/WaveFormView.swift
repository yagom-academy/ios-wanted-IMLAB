//
//  WaveFormView.swift
//  VoiceRecorder
//
//  Created by jamescode on 2022/07/04.
//

import UIKit


enum WaveFormViewMode {
    case play
    case record
}

class WaveFormView: UIView {
    
    // MARK: - Properties
    
    var waveFormViewDataType: WaveFormViewMode = .record
    var waveforms = [Float]()
    private var caLayer: CAShapeLayer!
    private let barWidth: CGFloat = 4.0
    private var count = 0
    
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
    
    private func shiftWaveform() {
        
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
        
        if waveFormViewDataType == .record {
            drawRecordViewWaveForm()
        } else {
            drawPlayViewWaveForm()
        }
    }
    
    private func drawPlayViewWaveForm() {
        
        count = 0
        let path: UIBezierPath!
        
        if let layerPath = caLayer.path {
            path = UIBezierPath(cgPath: layerPath)
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
    
    private func drawRecordViewWaveForm() {
        
        shiftWaveform()
        count += 1
        
        let path: UIBezierPath!
        
        if let layerPath = caLayer.path {
            path = UIBezierPath(cgPath: layerPath)
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
