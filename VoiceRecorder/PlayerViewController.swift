//
//  PlayerViewController.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import UIKit

class PlayerViewController: UIViewController {
    private var safearea: UILayoutGuide!

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

    init() {
        super.init(nibName: nil, bundle: nil)

        attribute()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func attribute() {
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

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing

        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
            backwardButton, playPauseButton, forwardButton
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
