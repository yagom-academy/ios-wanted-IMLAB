//
//  ProgressTimeView.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/05.
//

import UIKit

class ProgressTimeView: UIView {
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    let playTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()
    
    let playTimeRemainLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProgressTimeView {
    func configure() {
        addSubViews()
        makeConstraints()
    }
    
    func addSubViews() {
        [progressView, playTimeLabel, playTimeRemainLabel].forEach {
            addSubview($0)
        }
    }
    
    func makeConstraints() {
        [progressView, playTimeLabel, playTimeRemainLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            playTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8.0),
            playTimeLabel.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            
            playTimeRemainLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8.0),
            playTimeRemainLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
        ])
    }
}
