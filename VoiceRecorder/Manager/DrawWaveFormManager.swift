//
//  DrawWaveFormManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/29.
//

import UIKit
import AVFoundation

protocol DrawWaveFormManagerDelegate : AnyObject {
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
    private var waveFormImage : UIImage!
    private var start : CGPoint!
    private var step : CGFloat!
    weak var delegate : DrawWaveFormManagerDelegate?
    
    func startDrawing(of recorder : AVAudioRecorder, in view : UIView){
        prepareDrawing(in: view)
        timer = Timer.scheduledTimer(withTimeInterval: 1/14, repeats: true, block: { timer in
            recorder.updateMeters()
            self.drawWaveForm(recorder.averagePower(forChannel: 0), in: view)
        })
    }
    
    func stopDrawing(in view : UIView) {
        timer.invalidate()
        waveFormImage = getUIImage(from: view)
        saveImageInLocal(waveFormImage)
    }
    
    func getWaveFormImage() -> UIImage {
        return waveFormImage
    }
    
    private func prepareDrawing(in view : UIView){
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
    
    private func removeWaveForm() {
        pencil.removeAllPoints()
        waveLayer.removeFromSuperlayer()
        delegate?.resetWaveFormView()
    }
    
    private func drawWaveForm(_ input : Float, in view : UIView) {
        let newInput = pow(10, input / 20)
        let viewHeight = view.bounds.height
        let maxTraitLength = (viewHeight/2) - 10
        let minTraitLength = viewHeight/100
        let newTraitLength = ((CGFloat(newInput) * (maxTraitLength - minTraitLength))) + minTraitLength
        
        traitLength = newInput > 1 ? maxTraitLength : newTraitLength

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
        
        start = CGPoint(x: start.x + jump, y: start.y)
        step += jump
        delegate?.moveWaveFormView(step)
        
    }
    
    private func getUIImage(from view: UIView) -> UIImage {
        let resizedBounds = CGRect(x: view.bounds.maxX, y: view.bounds.minY, width: step, height: view.bounds.height)
        let renderer = UIGraphicsImageRenderer(bounds: resizedBounds)
        return renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
    }
    
    
    private func saveImageInLocal(_ imageUI: UIImage) {
        let imageFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myWaveForm.png")
        let imageData = imageUI.pngData()
        do {
            try imageData?.write(to: imageFileURL)
        }
        catch {
            print("error - saveImageInLocal")
        }
    }
    
}
