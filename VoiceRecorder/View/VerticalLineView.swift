//
//  VerticalLineView.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/06.
//

import UIKit

class VerticalLineView: UIView {
    
    private var path: UIBezierPath!
    private var shape: CAShapeLayer!
    private var screenRect : CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        screenRect = UIScreen.main.bounds
        self.frame.size.width = screenRect.size.width
        self.frame.size.height = screenRect.size.height * (0.15)
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        
        shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = screenRect.size.width/112/10
        
        self.layer.addSublayer(shape)
    }
}
