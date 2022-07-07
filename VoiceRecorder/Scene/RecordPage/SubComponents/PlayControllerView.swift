//
//  PlayContollerView.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation
import UIKit

class PlayControllerView: UIStackView {
    private var viewModel: PlayControllerViewModel!
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "gobackward.5", state: .normal)
        button.tintColor = .label

        button.addTarget(self, action: #selector(didTapBackwardButton(sender:)), for: .touchUpInside)

        return button
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "play.fill", state: .normal)
        button.setImage(systemName: "pause.fill", state: .selected)
        button.tintColor = .label

        button.addTarget(self, action: #selector(didTapPlayButton(sender:)), for: .touchUpInside)

        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "goforward.5", state: .normal)
        button.tintColor = .label

        button.addTarget(self, action: #selector(didTapForwardButton(sender:)), for: .touchUpInside)

        return button
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEnded), name: NSNotification.Name("PlayerDidEnded"), object: nil)
        
        attribute()
        layout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Action 함수
    @objc private func playerDidEnded() {
        playButton.isSelected = false
    }
    
    @objc func didTapBackwardButton(sender: UIButton) {
        viewModel.goBackward()
    }

    @objc func didTapForwardButton(sender: UIButton) {
        viewModel.goForward()
    }

    @objc func didTapPlayButton(sender: UIButton) {
        sender.isSelected = viewModel.playPauseAudio()
    }
    
    func bind(_ viewModel: PlayControllerViewModel) {
        self.viewModel = viewModel
    }
    
    private func attribute() {
        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.spacing = 40
        self.isHidden = true
    }
    
    private func layout() {
        [backwardButton, playButton, forwardButton].forEach {
            self.addArrangedSubview($0)
        }
        
        backwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        forwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
