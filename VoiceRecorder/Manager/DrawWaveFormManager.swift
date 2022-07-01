//
//  DrawWaveFormManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/29.
//

import UIKit
import AVFoundation

protocol DrawWaveFormDelegate {
    func moveWaveFormView(_ step: CGFloat)
    func resetWaveFormView()
}

class DrawWaveFormManager{
    
    private var timer : Timer!
    private var pencil : UIBezierPath!
    private var firstPoint : CGPoint!
    private var jump : CGFloat!
    private var waveLayer : CAShapeLayer!
    private var traitLength : CGFloat!
    private var start : CGPoint!
    private var step : CGFloat!
    
    var delegate : DrawWaveFormDelegate?
    
    func prepareDrawing(in view : UIView){
        if pencil != nil && waveLayer != nil {
            removeWaveForm()
        }
        pencil = UIBezierPath()
        firstPoint = CGPoint(x: (view.bounds.width), y: (view.bounds.midY))
        jump = view.bounds.width/112
        waveLayer = CAShapeLayer()
        start = firstPoint
        step = 0
    }
    
    func startDrawing(of recorder : AVAudioRecorder, in view : UIView){
        prepareDrawing(in: view)
        timer = Timer.scheduledTimer(withTimeInterval: 1/14, repeats: true, block: { timer in
            recorder.updateMeters()
            self.drawWaveForm(recorder.averagePower(forChannel: 0), in: view)
        })
    }
    
    func stopDrawing(){
        timer.invalidate()
        
    }
    
    func removeWaveForm() {
        pencil.removeAllPoints()
        waveLayer.removeFromSuperlayer()
        delegate?.resetWaveFormView()
    }
    
    func drawWaveForm(_ input : Float, in view : UIView) {

        let viewHeight = view.bounds.height
        let maxTraitLength = (viewHeight/2) - 10
        let minTraitLength = viewHeight/100
        let newTraitLength = ((CGFloat(input + 55) * (maxTraitLength - minTraitLength))/55) + minTraitLength
        
        switch input {
        case ..<(-55):
            traitLength = minTraitLength
        case (-55)..<(-40):
            traitLength = max(minTraitLength, newTraitLength * (7/10))
        case (-40)..<(-20):
            traitLength = max(minTraitLength, newTraitLength * (8/10))
        case (-20)..<(-1):
            traitLength = newTraitLength
        default:
            traitLength = maxTraitLength
        }
        
//        print("input: \(input)")
        
        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))

        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y - traitLength))
        
        waveLayer.strokeColor = UIColor.red.cgColor
        
        waveLayer.path = pencil.cgPath
        waveLayer.fillColor = UIColor.systemGray6.cgColor
        
        waveLayer.lineWidth = jump/10
        
        view.layer.addSublayer(waveLayer)
        waveLayer.contentsCenter = view.frame
        
        view.setNeedsDisplay()
        
        start = CGPoint(x: start.x + jump, y: start.y)
        delegate?.moveWaveFormView(step)
        step -= jump
    }
}
