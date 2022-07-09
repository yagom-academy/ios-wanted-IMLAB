//
//  PlayerViewController.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import UIKit

class PlayerViewController: UIViewController {
    private let viewModel = PlayerViewModel(PlayerManager.shared, RecordNetworkManager.shared)
    private var safearea: UILayoutGuide!

    private var waves: [Int] = []

    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)

        return label
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill

        return stackView
    }()

    private let frequencyView = FrequencyView(frame: .zero)
    private let pitchControlView = PitchControlView(frame: .zero)
    private let volumeControlView = VolumeControlView(frame: .zero)
    private let playerButtonView = PlayerButtonView(frame: .zero)

    init() {
        super.init(nibName: nil, bundle: nil)

        bind()
        attribute()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        viewModel.resetAudioPlayer()
        frequencyView.removeObserver()
        playerButtonView.resetSettings()
    }
}

// MARK: - Attribute, Layout

extension PlayerViewController {
    private func bind() {
        playerButtonView.bind(viewModel.playerButtonViewModel)
        pitchControlView.bind(viewModel.pitchViewModel)
        volumeControlView.bind(viewModel.volumeViewModel)
    }

    private func attribute() {
        title = "녹음파일 재생"
        view.backgroundColor = .white

        safearea = view.safeAreaLayoutGuide
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
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ]

        NSLayoutConstraint.activate(mainStackViewConstraints)

        // 파일명, 파형, 음성변조, 볼륨, 버튼
        let mainStackViewItems = [
            frequencyView,
            fileNameLabel,
            playerButtonView,
            volumeControlView,
            pitchControlView,
//            speedControlView,
        ]

        mainStackViewItems.forEach {
            self.mainStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let mainStackViewItemsContraints = [
            frequencyView.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.3),
            frequencyView.topAnchor.constraint(equalTo: safearea.topAnchor, constant: 30),
            fileNameLabel.heightAnchor.constraint(equalToConstant: 50),
            playerButtonView.heightAnchor.constraint(equalToConstant: 80),
            volumeControlView.heightAnchor.constraint(equalToConstant: 30),
            pitchControlView.heightAnchor.constraint(equalToConstant: 30),
//            speedControlView.heightAnchor.constraint(equalToConstant: 20),
        ]

        mainStackView.setCustomSpacing(80, after: fileNameLabel)
        mainStackView.setCustomSpacing(30, after: playerButtonView)
        mainStackView.setCustomSpacing(30, after: volumeControlView)
        mainStackView.setCustomSpacing(20, after: pitchControlView)

        NSLayoutConstraint.activate(mainStackViewItemsContraints)
    }
}

// MARK: - Actions, States

extension PlayerViewController {
    // 재생상태 초기화
    @objc private func audioDidEnd(notification: NSNotification) {
        print("player ended!")
        viewModel.setPlayerToZero()
    }
}

extension PlayerViewController {
    func setData(_ filedata: FileData) {
        viewModel.update(filedata) { error in
            if let error = error {
                self.isInvalidFile()
                return
            }

            self.getWaveData(filedata.rawFilename)
            self.playerButtonView.bindDuration(filedata.duration)
        }
    }

    private func getWaveData(_ filename: String) {
        viewModel.waveData(filename) { result in
            guard let result = result else {
                return
            }

            self.waves = result

            NotificationCenter.default.post(name: Notification.Name("GetWaves"), object: result)

            NotificationCenter.default.post(name: Notification.Name("ButtonEnabled"), object: result)

            self.configurePlayer()
        }
    }

    func configurePlayer() {
        let fileData = viewModel.getFileData()

        fileNameLabel.text = fileData?.filename

        viewModel.setPlayerItem()
    }

    func isInvalidFile() {
        let alert = UIAlertController(title: "오류", message: "녹음 파일을 여는데 실패했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true)
    }
}
