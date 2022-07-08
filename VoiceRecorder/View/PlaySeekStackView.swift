//
//  PlaySeekView.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/05.
//

import UIKit

protocol PlaySeekStackViewDelegate: AnyObject {
    func touchBackwardButton()
    func touchForwardButton()
    func touchPlayPauseButton()
}

final class PlaySeekStackView: UIStackView {
    private lazy var backwardButton: UIButton = {
        let button = UIButton().makePlaySeekButton(UIImage.gobackward)
        button.addTarget(self, action: #selector(touchBackwardButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton().makePlaySeekButton(UIImage.goforward)
        button.addTarget(self, action: #selector(touchForwardButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton().makePlaySeekButton(UIImage.playFill)
        button.addTarget(self, action: #selector(touchPlayPauseButton), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: PlaySeekStackViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension PlaySeekStackView {
    func configure() {
        addArrangedSubViews()
        setup()
    }
    
    func addArrangedSubViews() {
        [backwardButton, playPauseButton, forwardButton].forEach {
            addArrangedSubview($0)
        }
    }
    
    func setup() {
        distribution = .fillEqually
    }
    
    @objc func touchBackwardButton() {
        delegate?.touchBackwardButton()
    }
    
    @objc func touchForwardButton() {
        delegate?.touchForwardButton()
    }
    
    @objc func touchPlayPauseButton() {
        delegate?.touchPlayPauseButton()
    }
}

// MARK: - Public

extension PlaySeekStackView {
    func isReady(_ isReady: Bool) {
        backwardButton.isEnabled = isReady ? true : false
        playPauseButton.isEnabled = isReady ? true : false
        forwardButton.isEnabled = isReady ? true : false
    }
    
    func configurePlayPauseButtonState(_ isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setImage(UIImage.pauseFill, for: .normal)
        } else {
            playPauseButton.setImage(UIImage.playFill, for: .normal)
        }
    }
}
