//
//  PlayImageView.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/06.
//

import UIKit

class PlayImageView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "microphone")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PlayImageView {
    func configure() {
        addSubViews()
        makeConstraints()
    }
    
    func addSubViews() {
        addSubview(imageView)
    }
    
    func makeConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2),
        ])
    }
}
