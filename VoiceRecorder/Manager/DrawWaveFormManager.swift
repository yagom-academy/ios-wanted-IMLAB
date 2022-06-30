//
//  DrawWaveFormManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/29.
//

import UIKit
import AVFoundation

class DrawWaveFormManager{
    
    private var timer : Timer!
    private var pencil : UIBezierPath!
    private var firstPoint : CGPoint!
    private var jump : CGFloat!
    private var waveLayer : CAShapeLayer!
    private var traitLength : CGFloat!
    private var start : CGPoint!
    
    func prepareDrawing(in view : UIView){
        if pencil != nil && waveLayer != nil {
            pencil.removeAllPoints()
            waveLayer.removeFromSuperlayer()
        }
        pencil = UIBezierPath()
        firstPoint = CGPoint(x: 0, y: (view.bounds.midY))
        jump = view.bounds.width/112
        waveLayer = CAShapeLayer()
        start = firstPoint
    }
    
    func startDrawing(of recorder : AVAudioRecorder, in view : UIView){
        prepareDrawing(in: view)
        timer = Timer.scheduledTimer(withTimeInterval: 1/14, repeats: true, block: { timer in
            recorder.updateMeters() // 마이크 평균 및 최대 전력값을 업데이트
            self.drawWaveForm(recorder.averagePower(forChannel: 0), in: view)
        })
    }
    
    func stopDrawing(){
        timer.invalidate()
        // view도 깨끗하게 만들고
    }
    
    func removeWaveForm(in view : UIView) {
        // 다 초기화하면 되겄지..
    }
    
    func drawWaveForm(_ input : Float, in view : UIView) {

        let viewHeight = view.bounds.height
        let maxTraitLength = (viewHeight/2) - 10
        let minTraitLength = 1/viewHeight
        
        switch input {
        case ..<(-55):
            traitLength = minTraitLength
        case (-55)..<(-40):
            traitLength = (maxTraitLength + minTraitLength) * (7/10) * CGFloat(input) / -65
        case (-40)..<(-20):
            traitLength = (maxTraitLength + minTraitLength) * (8/10) * CGFloat(input) / -65
        case (-20)..<(-1):
            traitLength = (maxTraitLength + minTraitLength) * CGFloat(input) / -65
        default:
            traitLength = maxTraitLength
        }
        
        print("input: \(input)")
        
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
    }
}
