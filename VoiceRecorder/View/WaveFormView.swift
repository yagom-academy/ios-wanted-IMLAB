//
//  WaveFormView.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/06.
//

import UIKit

class WaveFormView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray6
        setView()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame.size.width = CGFloat(FP_INFINITE)
        imageView.contentMode = .left
        return imageView
    }()
    
    let verticalLineView: VerticalLineView = {
        let verticalLineView = VerticalLineView()
        verticalLineView.translatesAutoresizingMaskIntoConstraints = false
        return verticalLineView
    }()
    
    private func setView(){
        self.addSubview(imageView)
        self.addSubview(verticalLineView)
    }
    
    private func autoLayout(){
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            
            verticalLineView.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            verticalLineView.widthAnchor.constraint(equalTo: self.widthAnchor),
            verticalLineView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
}

