//
//  PitchControllerView.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/02.
//

import UIKit

class PitchControlView: UIView {
    /*
     bind 는 모든 곳에 다 있고
     subView 마다 viewModel 있음
     bind 랑 cell configure 랑 비슷

     메인 뷰모델에는 서브뷰모델 가지고 있음
     메인 뷰컨은 바인드 자기가 호출
     거기서 서브뷰랑 바인드 함수 호출해서 연결
     */

    private var viewModel: PitchViewModel!

    private let pitchControlLabel: UILabel = {
        let label = UILabel()
        label.text = "음성 변조"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label

        return label
    }()

    private let pitchControl: UISegmentedControl = {
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
        [
            pitchControlLabel,
            pitchControl,
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let pitchControlLabelConstraints = [
            pitchControlLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            pitchControlLabel.topAnchor.constraint(equalTo: topAnchor),
        ]

        let pitchControlConstraints = [
            pitchControl.topAnchor.constraint(equalTo: pitchControlLabel.bottomAnchor, constant: 8),
            pitchControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            pitchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
        ]

        [
            pitchControlLabelConstraints,
            pitchControlConstraints,
        ].forEach {
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
