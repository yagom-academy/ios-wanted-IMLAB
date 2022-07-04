//
//  VolumeControlView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/02.
//

import UIKit

class VolumeControlView: UIView {
    private var viewModel: VolumeViewModel!

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10

        return stackView
    }()

    private let volumeImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.wave.2.fill"))
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true

        return imageView
    }()

    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0

        slider.addTarget(self, action: #selector(onChangedVolume(_:)), for: .valueChanged)

        return slider
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VolumeControlView {
    func bind(_ viewModel: VolumeViewModel) {
        self.viewModel = viewModel
    }

    private func layout() {
        [volumeImage, volumeSlider].forEach {
            stackView.addArrangedSubview($0)
        }

        [stackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let inset: CGFloat = 30.0

        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
        ]

        NSLayoutConstraint.activate(stackViewConstraints)
    }
}

extension VolumeControlView {
    @objc private func onChangedVolume(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / 0.1) * 0.1
        sender.value = roundedStepValue

        viewModel.changedVolume(sender.value)
    }
}
