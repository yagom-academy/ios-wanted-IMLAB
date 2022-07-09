//
//  RecordWaveForm.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import UIKit

class RecordWaveForm: UIView {

    private lazy var pencil = UIBezierPath(rect: self.bounds)
       private var waveLayer = CAShapeLayer()
       private var traitLength : CGFloat?
       private lazy var startPoint : CGPoint = CGPoint(x: 6, y: self.bounds.midY)

       func resetWaves(scrollview : UIScrollView) {
           pencil.removeAllPoints()
           waveLayer.removeFromSuperlayer()
           scrollview.setContentOffset(CGPoint(x: self.frame.minX, y: 0.0), animated:false)
           startPoint = CGPoint(x: 6, y: self.bounds.midY)
       }

       func writeWaves(_ input: Float, scrollview : UIScrollView) {

           if startPoint.x == 6 {
               pencil.removeAllPoints()
               waveLayer.removeFromSuperlayer()
           }

           if startPoint.x >= self.frame.maxX {
               scrollview.setContentOffset(CGPoint(x: startPoint.x - (self.frame.maxX * 0.9), y: 0.0), animated:true)

           } else {
               scrollview.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
           }

           if input < -55 {
               traitLength = 0.2
           } else if input < -40 && input > -55 {
               traitLength = (CGFloat(input) + 56) / 3
           } else if input < -20 && input > -40 {
               traitLength = (CGFloat(input) + 41) / 2
           } else if input < -10 && input > -20 {
               traitLength = (CGFloat(input) + 21) * 5
           } else {
               traitLength = (CGFloat(input) + 20) * 4
           }

           guard let traitLength = traitLength else {
               return
           }

           pencil.lineWidth = 4

           pencil.move(to: startPoint)
           pencil.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + traitLength))

           pencil.move(to: startPoint)
           pencil.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y - traitLength))

           waveLayer.strokeColor = UIColor.orange.cgColor

           waveLayer.path = pencil.cgPath
           waveLayer.fillColor = UIColor.clear.cgColor
           waveLayer.backgroundColor = UIColor.clear.cgColor

           waveLayer.lineWidth = 4

           self.layer.addSublayer(waveLayer)
           waveLayer.contentsCenter = self.frame
           self.setNeedsDisplay()


           startPoint = CGPoint(x: startPoint.x + 5.0, y: startPoint.y)

       }

}
