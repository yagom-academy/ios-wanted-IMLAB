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

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let upperCenter = CGPoint(x: 0, y: 0)
        let bottomCenter = CGPoint(x: 0, y: frame.height)
        
        path = UIBezierPath()
        
        path.move(to: bottomCenter)
        path.addLine(to: upperCenter)
        
        shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = UIScreen.main.bounds.size.width/112/10
        
        self.layer.addSublayer(shape)
    }
}
