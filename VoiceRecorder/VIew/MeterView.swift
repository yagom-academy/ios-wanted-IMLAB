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
    lazy var scrollLayer: CAScrollLayer = {
        let scrollLayer = CAScrollLayer()
        scrollLayer.bounds = CGRect(x: 0, y: 0, width: 150, height: 80)
        scrollLayer.scrollMode = .horizontally
        return scrollLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDisPlayLink()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpDisPlayLink(){
        self.layer.backgroundColor = UIColor.gray.cgColor
        disPlayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        disPlayLink?.add(to: .current, forMode: .common)
        disPlayLink?.isPaused = true
    }
    
    @objc func updateDisplay(){
        let layer = CALayer()
        currentX += 0.1
        let value = value ?? 0
        let center = self.frame.height / 2
        var realValue = value * 100 > 80 ? 80:value * 100
        print(value * 100)
        layer.frame = .init(x: currentX, y: center, width: 1.5, height: realValue == 0 ? 10:realValue)
        layer.frame = layer.frame.offsetBy(dx: 0, dy: -realValue / 2)
        
        layer.backgroundColor = UIColor.systemBlue.cgColor
        
        layer.cornerCurve = .continuous
        
        self.layer.scroll(CGPoint(x: currentX, y: center))
        self.layer.addSublayer(scrollLayer)
        scrollLayer.addSublayer(layer)
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        
    }
}
