//
//  PlayerControlView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/02.
//

import UIKit

class PlayerButtonView: UIView {
    private var viewModel: PlayerButtonViewModel!

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 50

        return stackView
    }()

    let playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "play.fill", state: .normal)
        button.setImage(systemName: "pause.fill", state: .selected)
        button.tintColor = .label

        let buttonConstraints = [
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40),
        ]

        NSLayoutConstraint.activate(buttonConstraints)

        button.addTarget(self, action: #selector(onTappedPlayPauseButton(sender:)), for: .touchUpInside)

        return button
    }()

    let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "goforward.5", state: .normal)
        button.tintColor = .label

        let buttonConstraints = [
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40),
        ]

        NSLayoutConstraint.activate(buttonConstraints)

        button.addTarget(self, action: #selector(onTappedForwardButton(sender:)), for: .touchUpInside)

        return button
    }()

    let backwardButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "gobackward.5", state: .normal)
        button.tintColor = .label

        let buttonConstraints = [
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40),
        ]

        NSLayoutConstraint.activate(buttonConstraints)

        button.addTarget(self, action: #selector(onTappedBackwardButton(sender:)), for: .touchUpInside)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEnded), name: NSNotification.Name("PlayerDidEnded"), object: nil)

        attribute()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func playerDidEnded() {
        playPauseButton.isSelected = false
    }
    
    deinit {
        viewModel.resetViewModel()
    }
}

// MARK: - Layout

extension PlayerButtonView {
    func bind(_ viewModel: PlayerButtonViewModel) {
        self.viewModel = viewModel
    }

    private func attribute() {
        [backwardButton, playPauseButton, forwardButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func layout() {
        [stackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ]

        NSLayoutConstraint.activate(stackViewConstraints)
    }
}

// MARK: - Button Handler

extension PlayerButtonView {
    private func setPlayPauseButtonState(_ isPlaying: Bool) {
        playPauseButton.isSelected = isPlaying
    }

    @objc private func onTappedPlayPauseButton(sender: UIButton) {
        let isPlaying = viewModel.playPauseAudio()
        setPlayPauseButtonState(isPlaying)
    }

    @objc private func onTappedForwardButton(sender: UIButton) {
        viewModel.goForward()
    }

    @objc private func onTappedBackwardButton(sender: UIButton) {
        viewModel.goBackward()
    }
}
