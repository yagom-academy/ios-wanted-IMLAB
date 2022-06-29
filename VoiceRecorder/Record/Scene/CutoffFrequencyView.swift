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
    
    private let frequencySlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        
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
        
        cutoffLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cutoffLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
        
        frequencySlider.topAnchor.constraint(equalTo: cutoffLabel.bottomAnchor, constant: 8).isActive = true
        frequencySlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
        frequencySlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset).isActive = true
    }
}
