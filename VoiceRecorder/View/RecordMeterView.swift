//
//  MeterView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/04.
//

import Foundation
import UIKit

class RecordMeterView: UIView {
    var values: [CGFloat] = []
    private var currentX: CGFloat = 0.0

    var disPlayLink: CADisplayLink?
    
    required override init(frame:CGRect) {
        super.init(frame: frame)
        setUpDisPlayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpDisPlayLink()
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
        currentX += 0.1
        let calValue = calculateValue()
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.path = setupPath(calValue).cgPath
        
        updateScroll()
        
        self.layer.addSublayer(layer)
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
    }
    
    private func calculateValue() -> CGFloat {
        let value = values.last ?? 0
        return calNormal(input: value)
    }
    
    private func updateScroll() {
        var newPoint = self.bounds.origin
        newPoint.x += 0.1
        layer.scroll(newPoint)
    }
    
    private func setupPath(_ calValue:CGFloat) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY))
        bezierPath.addLine(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY + (calValue / 2)))
        
        bezierPath.move(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY))
        bezierPath.addLine(to: CGPoint(x: currentX + self.frame.width / 2, y: self.bounds.midY - (calValue / 2)))
        return bezierPath
    }
    
    private func calNormal(input:CGFloat) -> CGFloat{
        if input < 10 {
            return 1
        } else if input > 190 {
            return 190
        } else {
            return input
        }
    }
}
