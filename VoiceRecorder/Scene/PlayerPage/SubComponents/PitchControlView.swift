//
//  PitchControllerView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/02.
//

import UIKit

class PitchControlView: UIView {
    private var viewModel: PitchViewModel!

    private lazy var pitchControl: UISegmentedControl = {
        let items = ["일반 목소리", "아기 목소리", "할아버지 목소리"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0

        control.addTarget(self, action: #selector(onChangedPitch(_:)), for: .valueChanged)

        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PitchControlView {
    func bind(_ viewModel: PitchViewModel) {
        self.viewModel = viewModel
    }

    private func layout() {
        [pitchControl].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let pitchControlConstraints = [
            pitchControl.topAnchor.constraint(equalTo: topAnchor),
            pitchControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            pitchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            pitchControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]

        [pitchControlConstraints].forEach {
            NSLayoutConstraint.activate($0)
        }
    }
}

extension PitchControlView {
    @objc private func onChangedPitch(_ sender: UISegmentedControl!) {
        let index = Int(sender.selectedSegmentIndex)

        viewModel.changePitch(index)
    }
}
