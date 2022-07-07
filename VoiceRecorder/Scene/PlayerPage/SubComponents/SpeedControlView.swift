//
//  SpeedControlView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/07.
//

import Foundation
import UIKit

class SpeedControlView: UIView {
    private var viewModel: SpeedViewModel!

    private var speedRate: Float = 1.0

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        return stackView
    }()

    let speedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }()

    let speedUpButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "plus.circle.fill", state: .normal)
        button.tintColor = .systemBlue

        let buttonConstraints = [
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20),
        ]

        NSLayoutConstraint.activate(buttonConstraints)

        button.addTarget(self, action: #selector(onTappedSpeedUpButton(sender:)), for: .touchUpInside)

        return button
    }()

    let speedDownButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "minus.circle.fill", state: .normal)
        button.tintColor = .systemBlue

        let buttonConstraints = [
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20),
        ]

        NSLayoutConstraint.activate(buttonConstraints)

        button.addTarget(self, action: #selector(onTappedSpeedDownButton(sender:)), for: .touchUpInside)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        attribute()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SpeedControlView {
    func bind(_ viewModel: SpeedViewModel) {
        self.viewModel = viewModel
    }

    private func attribute() {
        speedLabel.text = "재생속도 \(speedRate)"

        [speedDownButton, speedLabel, speedUpButton].forEach {
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
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ]

        NSLayoutConstraint.activate(stackViewConstraints)
    }
}

extension SpeedControlView {
    private func setButtonState() {
        if speedRate >= 1.5 {
            speedUpButton.isEnabled = false
            speedDownButton.isEnabled = true
        } else if speedRate <= 0.5 {
            speedUpButton.isEnabled = true
            speedDownButton.isEnabled = false
        } else {
            speedUpButton.isEnabled = true
            speedDownButton.isEnabled = true
        }
        speedLabel.text = "재생속도 \(String(format: "%.1f", speedRate))"
        
    }
    
    @objc private func onTappedSpeedUpButton(sender: UIButton) {
        speedRate = viewModel.changeSpeed(+)
        setButtonState()
    }

    @objc private func onTappedSpeedDownButton(sender: UIButton) {
        speedRate = viewModel.changeSpeed(-)
        setButtonState()
    }
}
