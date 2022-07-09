//
//  PlayerControlView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/02.
//

import UIKit

class PlayerButtonView: UIView {
    private var viewModel: PlayerButtonViewModel!
    private var timer: Timer?

    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = ThemeColor.blue300

        return label
    }()

    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .secondaryLabel

        return label
    }()

    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        return stackView
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 50

        return stackView
    }()

    private lazy var playPauseButton: UIButton = {
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

    private lazy var forwardButton: UIButton = {
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

    private lazy var backwardButton: UIButton = {
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

        NotificationCenter.default.addObserver(self, selector: #selector(buttonEnabled(_:)), name: Notification.Name("ButtonEnabled"), object: nil)

        attribute()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func playerDidEnded() {
        playPauseButton.isSelected = false
        viewModel.setCurrentTime(0)
        timer?.invalidate()
    }

    @objc func buttonEnabled(_ notification: Notification) {
        playPauseButton.isEnabled = true
        backwardButton.isEnabled = true
        forwardButton.isEnabled = true
    }

    deinit {
        resetSettings()
    }
}

// MARK: - Layout

extension PlayerButtonView {
    func bind(_ viewModel: PlayerButtonViewModel) {
        self.viewModel = viewModel
    }

    func bindDuration(_ duration: String) {
        currentTimeLabel.text = "00:00"
        durationLabel.text = "/ \(duration)"
        viewModel.setDuration(duration)
    }

    func resetSettings() {
        viewModel.resetViewModel()
    }

    private func attribute() {
        [backwardButton, playPauseButton, forwardButton].forEach {
            stackView.addArrangedSubview($0)
            $0.tintColor = ThemeColor.blue600
            $0.isEnabled = false
        }

        [currentTimeLabel, durationLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }

    private func layout() {
        [labelStackView, stackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let constraints = [
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            stackView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Button Handler

extension PlayerButtonView {
    private func setPlayPauseButtonState(_ isPlaying: Bool) {
        playPauseButton.isSelected = isPlaying
    }

    private func handleTimer(_ isPlaying: Bool) {
        if isPlaying {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimeFires), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
        }
    }

    @objc private func onTimeFires() {
        viewModel.incrementCurrentTime(1)

        if viewModel.timeInRange() {
            currentTimeLabel.text = viewModel.secondsToString(viewModel.getCurrentTime())
        }
    }

    @objc private func onTappedPlayPauseButton(sender: UIButton) {
        let isPlaying = viewModel.playPauseAudio()
        setPlayPauseButtonState(isPlaying)
        handleTimer(isPlaying)
    }

    @objc private func onTappedForwardButton(sender: UIButton) {
        viewModel.goForward()
        viewModel.incrementCurrentTime(5)
    }

    @objc private func onTappedBackwardButton(sender: UIButton) {
        viewModel.goBackward()
        viewModel.incrementCurrentTime(-5)
    }
}
