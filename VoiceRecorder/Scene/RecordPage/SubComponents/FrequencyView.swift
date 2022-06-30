//
//  FrequencyView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class FrequencyView: UIView {
    private let frequencyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FrequencyView {
    private func layout() {
        [
            frequencyImage
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        frequencyImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        frequencyImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        frequencyImage.widthAnchor.constraint(equalToConstant: 300).isActive = true
        frequencyImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
