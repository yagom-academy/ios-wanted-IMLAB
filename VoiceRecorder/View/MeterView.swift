//
//  MeterView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/04.
//

import Foundation
import UIKit

class RecordMeterView: UIView {
    var value:[CGFloat] = []
    var currentX:CGFloat = 0.0
    var disPlayLink:CADisplayLink?
    
    var myLayer = CALayer()
    lazy var startPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    lazy var jump: CGFloat = (self.bounds.width - (startPoint.x * 2)) / 200
    var start: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDisPlayLink()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAScrollLayer.self
    }
    
    func setUpDisPlayLink(){
        self.layer.backgroundColor = UIColor.gray.cgColor
        disPlayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        disPlayLink?.add(to: .current, forMode: .common)
        disPlayLink?.isPaused = true
    }
    
    @objc func updateDisplay() {
        //        let centerHeight = self.frame.height / 2
        //        let centerWidth = self.frame.width / 2
        //        let layer = CALayer()
        //        let secondLayer = CALayer()
        //
        //        currentX += 0.1
        //        let value = value.last ?? 0
        //        print(value)
        //
        //        layer.frame = .init(x: currentX + centerWidth, y: centerHeight, width: 2, height: calNormal(input: value))
        //        secondLayer.frame = .init(x: currentX + centerWidth, y: centerHeight, width: 1.0, height: calNormal(input: value))
        //
        //
        //        layer.backgroundColor = UIColor.systemBlue.cgColor
        //        layer.cornerCurve = .continuous
        //
        //
        
        currentX += 0.1
        let value = value.last ?? 0
        let calValue = calNormal(input: value)
        
        let pencil = UIBezierPath()
        pencil.move(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY))
        pencil.addLine(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY + (calValue / 2)))
        
        pencil.move(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY))
        pencil.addLine(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY - (calValue / 2)))
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.path = pencil.cgPath
        
        self.layer.addSublayer(layer)
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        
        var newPoint = self.bounds.origin
        newPoint.x += 0.1
        self.layer.scroll(newPoint)
    }
    
    private func calNormal(input:CGFloat) -> CGFloat{
        if input < 1 {
            return 1
        } else if input > 80 {
            return 78
        } else {
            return input
        }
    }
}
