//
//  MeterView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/04.
//

import Foundation
import UIKit

class RecordMeterView: UIView {
    var value:CGFloat?
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
        let centerHeight = self.frame.height / 2
        let centerWidth = self.frame.width / 2
//        print(centerWidth)
        let layer = CALayer()
        currentX += 0.1
        let value = value ?? 0
        
        print(value)
        
        var realValue = value * 100 > 80 ? 80:value * 100
        
        self.layer.addSublayer(myLayer)
        layer.frame = .init(x: currentX + centerWidth, y: centerHeight, width: 1.0, height: realValue)
        layer.frame = layer.frame.offsetBy(dx: 0, dy: -realValue / 2)


        layer.backgroundColor = UIColor.systemBlue.cgColor
        layer.cornerCurve = .continuous

        var newPoint = self.bounds.origin
        newPoint.x += 0.1

        self.layer.addSublayer(layer)
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        
        self.layer.scroll(newPoint)
    }
}
