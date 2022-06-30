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
        pencil = UIBezierPath(rect: view.bounds)
        firstPoint = CGPoint(x: 6, y: (view.bounds.midY))
        jump = (view.bounds.width - (firstPoint.x * 2))/200
        waveLayer = CAShapeLayer()
        start = firstPoint
    }
    
    func startDrawing(of recorder : AVAudioRecorder, in view : UIView){
        prepareDrawing(in: view)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { timer in
            recorder.updateMeters() // 마이크 평균 및 최대 전력값을 업데이트
            self.drawWaveForm(recorder.averagePower(forChannel: 0), in: view)
        })
    }
    
    func stopDrawing(of recorder : AVAudioRecorder, in view : UIView){
        
        // 타이머를 종료하고
        // view도 깨끗하게 만들고
    }
    
    func removeWaveForm(in view : UIView) {
        // 다 초기화하면 되겄지..
    }
    
    func drawWaveForm(_ input : Float, in view : UIView) {
        // 일단은 따라 써보자.
        
        switch input {
        case ..<(-55):
            traitLength = 0.2
        case (-55)..<(-40):
            traitLength = (CGFloat(input) + 56)/3
        case (-40)..<(-20):
            traitLength = (CGFloat(input) + 41)/2
        case (-20)..<(-10):
            traitLength = (CGFloat(input) + 21)*5
        default:
            traitLength = (CGFloat(input) + 20)*4
        }
        
        pencil.lineWidth = jump
        
        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
        
        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
        
        waveLayer.strokeColor = UIColor.black.cgColor
        
        waveLayer.path = pencil.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor
        
        waveLayer.lineWidth = jump
        
        view.layer.addSublayer(waveLayer)
        waveLayer.contentsCenter = view.frame
        
        view.setNeedsDisplay()
        
        start = CGPoint(x: start.x + jump, y: start.y)
    }
}
