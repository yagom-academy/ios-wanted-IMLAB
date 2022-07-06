//
//  FrequencyView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class FrequencyView: UIView {
    
    let manager = RecordManager.shared
    
    var barWidth: CGFloat = 40.0
    
    var color = UIColor.red.cgColor
    var waveForms = [Int](repeating: 0, count: 10)
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func draw(_ rect: CGRect) {
        print("in draw")
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        var bar: CGFloat = 0
        
        context.clear(rect)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
        context.fill(rect)
        context.setLineWidth(2)
        context.setStrokeColor(self.color)
        
        let centerY = rect.size.height / 2
        
        for i in 0..<self.waveForms.count {
            let firstX = bar * self.barWidth
            let firstY = centerY + CGFloat(self.waveForms[i])
            
            context.move(to: CGPoint(x: firstX, y: centerY))
            context.addLine(to: CGPoint(x: firstX, y: firstY))
            context.strokePath()
            
            bar += 1
        }
    }
}
