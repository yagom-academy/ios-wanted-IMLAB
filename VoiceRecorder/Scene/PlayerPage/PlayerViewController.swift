//
//  PlayerViewController.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import UIKit

class PlayerViewController: UIViewController {
    private let viewModel = PlayerViewModel()
    private var safearea: UILayoutGuide!

    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center

        return label
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

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

        NotificationCenter.default.addObserver(self, selector: #selector(audioDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        // TODO: - 화면 나갈때 audioPlayer 해제 (멈추게), 재생 끝날때 다시 처음으로 초기화
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
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 30),
        ]

        NSLayoutConstraint.activate(mainStackViewConstraints)

        // 파일명, 파형, 음성변조, 볼륨, 버튼
        let mainStackViewItems = [
            fileNameLabel,
            frequencyView,
            pitchControlView,
            playerButtonView,
            volumeControlView,
        ]

        mainStackViewItems.forEach {
            self.mainStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let mainStackViewItemsContraints = [
            fileNameLabel.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.1),
            frequencyView.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.3),
            pitchControlView.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.1),
            volumeControlView.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.1),
            playerButtonView.heightAnchor.constraint(equalTo: safearea.heightAnchor, multiplier: 0.1),
        ]

        NSLayoutConstraint.activate(mainStackViewItemsContraints)
    }
}

// MARK: - Actions, States

extension PlayerViewController {
    // 재생상태 초기화
    @objc private func audioDidEnd(notification: NSNotification) {
//        viewModel.setPlayerToZero()
    }
}

extension PlayerViewController {
    func setData(_ filename: String) {
        viewModel.update(filename) { error in
            if let error = error {
                self.isInvalidFile()
                return
            }

            self.configurePlayer()
        }
    }

    func configurePlayer() {
        let fileData = viewModel.getFileData()

        fileNameLabel.text = fileData?.fileName

        viewModel.setPlayerItem()
        viewModel.setAudioReady()
    }

    func isInvalidFile() {
        let alert = UIAlertController(title: "오류", message: "녹음 파일을 여는데 실패했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true)
    }
}
