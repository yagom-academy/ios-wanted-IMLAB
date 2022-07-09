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
    
    var waveFormViewMode: WaveFormViewMode = .record
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
            let transform  = CATransform3DTranslate(layer.transform, -1, 0, 0)
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
        
        if waveFormViewMode == .record {
            drawRecordViewWaveForm()
        } else {
            drawPlayViewWaveForm()
        }
    }
    
    private func drawPlayViewWaveForm() {
        
        count = 0
        
        let path: UIBezierPath = createBezierPath()
        
        for wave in waveforms {
            count += 1
            createWaveFormBar(with: wave, path: path, mode: .play)
            
            caLayer.path = path.cgPath
        }
    }
    
    private func drawRecordViewWaveForm() {
        
        shiftWaveform()
        count += 1
        
        let path: UIBezierPath = createBezierPath()
        
        guard let wave = waveforms.last else { return }
        createWaveFormBar(with: wave, path: path, mode: .record)
        
        caLayer.path = path.cgPath
    }
    
    private func createBezierPath() -> UIBezierPath {
        
        let path: UIBezierPath
        
        if let layerPath = caLayer.path {
            path = UIBezierPath(cgPath: layerPath)
        } else {
            path = UIBezierPath()
        }
        
        return path
    }
    
    private func validateWaveFormData(wave: Float) -> Float {
        
        var waveData = max(0.02, wave)
        waveData = min(1, waveData)
        
        return waveData
    }
    
    private func createWaveFormBar(with wave: Float, path: UIBezierPath, mode: WaveFormViewMode) {
        
        let waveData = validateWaveFormData(wave: wave)
        
        let startX = mode == .play ?
        self.bounds.origin.x + 1 * CGFloat(count) :
        self.bounds.width + 1 * CGFloat(count)
        
        let startY = self.bounds.height / 2

        path.move(to: CGPoint(x: startX, y: startY + CGFloat(waveData * Float(self.bounds.height) / 2)))
        path.addLine(to: CGPoint(x: startX, y: startY - CGFloat(waveData * Float(self.bounds.height) / 2)))
    }
    
}
