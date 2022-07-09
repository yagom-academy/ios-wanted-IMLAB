//
//  CutoffFrequencyView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class CutoffFrequencyView: UIView {
    private let cutoffLabel: UILabel = {
        let label = UILabel()
        label.text = "cutoff freqency"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label

        return label
    }()

    private lazy var frequencySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 60.0
        slider.value = 60.0

        slider.addTarget(self, action: #selector(didChangeSlider(_:)), for: .valueChanged)

        return slider
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action
    @objc func didChangeSlider(_ sender: UISlider) {
        let cutValue = sender.value

        NotificationCenter.default.post(name: Notification.Name("SendCutValue"), object: cutValue, userInfo: nil)
    }
}

extension CutoffFrequencyView {
    private func layout() {
        [
            cutoffLabel,
            frequencySlider
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let inset: CGFloat = 30.0

        cutoffLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        cutoffLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true

        frequencySlider.topAnchor.constraint(equalTo: cutoffLabel.bottomAnchor, constant: 8).isActive = true
        frequencySlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
        frequencySlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset).isActive = true
    }
}
