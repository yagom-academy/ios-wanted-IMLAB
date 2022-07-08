//
//  ProgressTimeView.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/05.
//

import UIKit

class ProgressTimeView: UIStackView {
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    private let playTimeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TimeLabelText.zero
        return label
    }()
    
    private let playTimeRemainLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TimeLabelText.zero
        return label
    }()
    
    private lazy var timeLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [playTimeLabel, playTimeRemainLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension ProgressTimeView {
    func configure() {
        addArrangedSubViews()
        setup()
    }
    
    func addArrangedSubViews() {
        [progressView, timeLabelStackView].forEach {
            addArrangedSubview($0)
        }
    }
    
    func setup() {
        axis = .vertical
        spacing = 10
        distribution = .equalSpacing
    }
}

// MARK: - Public

extension ProgressTimeView {
    func configureProgressValue(_ value: Float) {
        progressView.progress = value
    }
    
    func configureTimeText(_ playerTime: PlayerTime) {
        playTimeLabel.text = playerTime.elapsedText
        playTimeRemainLabel.text = playerTime.remainingText
    }
}
