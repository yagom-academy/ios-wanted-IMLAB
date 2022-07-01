//
//  PlayerViewController.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import UIKit

class PlayerViewController: UIViewController {
    private var safearea: UILayoutGuide!
    private let viewModel = PlayerViewModel()

    private let mainStackView = UIStackView()
    private let buttonStackView = UIStackView()

    private let fileNameLabel = UILabel()
    private let soundWaveView = UIView()
    private let pitchControl = UISegmentedControl(items: ["일반 목소리", "아기 목소리", "할아버지 목소리"])
    private let sliderTitleLabel = UILabel()
    private let volumeSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 300, height: 20))

    private let playPauseButton = UIButton()
    private let forwardButton = UIButton()
    private let backwardButton = UIButton()

    private var isPlaying = false

    private let sampleURL = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/sampleapp-9e55d.appspot.com/o/audio%2F2022.06.27_18:05:55%2B11.m4a?alt=media&token=1a9cd60b-95cd-4a39-ad25-7adea9eebd19")

    init() {
        super.init(nibName: nil, bundle: nil)

        attribute()
        layout()

        // 버튼 핸들러 추가
        configureHandler()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        NotificationCenter.default.addObserver(self, selector: #selector(audioDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

// MARK: - Attribute, Layout

extension PlayerViewController {
    private func attribute() {
//        title = "녹음파일 재생"

        safearea = view.safeAreaLayoutGuide

        view.backgroundColor = .white

        mainStackView.backgroundColor = .white
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill

        fileNameLabel.text = "2022.06.29 11:21:38"
        fileNameLabel.textAlignment = .center

        soundWaveView.backgroundColor = .lightGray

        pitchControl.selectedSegmentIndex = 0

        sliderTitleLabel.text = "Volume"

        volumeSlider.isContinuous = false
        volumeSlider.maximumValue = 1
        volumeSlider.minimumValue = 0
        volumeSlider.value = 0.5

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing

        setPlayPauseButtonState()
        playPauseButton.isEnabled = false
        playPauseButton.backgroundColor = .systemBlue.withAlphaComponent(0.3)

        forwardButton.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        forwardButton.backgroundColor = .systemBlue.withAlphaComponent(0.3)

        backwardButton.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        backwardButton.backgroundColor = .systemBlue.withAlphaComponent(0.3)
    }

    private func layout() {
        // 전체 화면 StackView
        [mainStackView].forEach {
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let mainStackViewConstraints = [
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]

        NSLayoutConstraint.activate(mainStackViewConstraints)

        // 파일명, 파형, 음성변조, 볼륨, 버튼
        let mainStackViewItems = [
            fileNameLabel,
            soundWaveView,
            pitchControl,
            sliderTitleLabel,
            volumeSlider,
            buttonStackView,
        ]

        mainStackViewItems.forEach {
            self.mainStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false

            let constraints = [
//                $0.heightAnchor.constraint(equalToConstant: 100),
                $0.leadingAnchor.constraint(equalTo: safearea.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: safearea.trailingAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }

        // 버튼
        let buttonStackViewItems = [
            backwardButton, playPauseButton, forwardButton,
        ]

        buttonStackViewItems.forEach {
            buttonStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false

            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true

            $0.layer.cornerRadius = 25
        }
    }
}

// MARK: - Actions, States

extension PlayerViewController {
    // 버튼 이미지 관리
    private func setPlayPauseButtonState() {
        if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }

    // 핸들러 추가
    private func configureHandler() {
        pitchControl.addTarget(self, action: #selector(handlePitchControl), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(handleVolumeSlider), for: .valueChanged)
        playPauseButton.addTarget(self, action: #selector(handlePlayPauseButton), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(handleBackwardButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(handleForwardButton), for: .touchUpInside)
    }

    @objc private func handlePitchControl(_ sender: UISegmentedControl!) {
        viewModel.changedPitchControl(sender.selectedSegmentIndex)
    }

    @objc private func handleVolumeSlider(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / 0.1) * 0.1
        sender.value = roundedStepValue

        viewModel.changedVolumeSlider(roundedStepValue)
    }

    // 재생, 일시정지 버튼
    @objc private func handlePlayPauseButton() {
        isPlaying = viewModel.onTappedPlayPauseButton()
        setPlayPauseButtonState()
    }

    // -5초
    @objc private func handleBackwardButton() {
        viewModel.onTappedBackwardButton()
    }

    // +5초
    @objc private func handleForwardButton() {
        viewModel.onTappedForwardButton()
    }

    // 재생상태 초기화
    @objc private func audioDidEnd(notification: NSNotification) {
        viewModel.setPlayerToZero()
        isPlaying.toggle()
        setPlayPauseButtonState()
    }
}

extension PlayerViewController {
    func setData(_ filename: String) {
        viewModel.update(filename) {
            self.configurePlayer()
        }
    }

    func configurePlayer() {
        let fileData = viewModel.getFileData()
        title = fileData?.fileName ?? "No File Found"

        viewModel.setPlayerItem()
        playPauseButton.isEnabled = true
    }
}
