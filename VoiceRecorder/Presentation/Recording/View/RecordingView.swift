//
//  RecordingView.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class RecordingView: UIView, ViewPresentable {
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .red
        return button
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "text"
        return label
    }()
    
    let goforward5Button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        return button
    }()
    
    let goBackward5Button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        return button
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        return slider
    }()
    
    private let playButtonHorizontalStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
         stackView.distribution = .fillEqually
         stackView.axis = .vertical
         stackView.alignment = .center
         return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [slider, timeLabel, playButtonHorizontalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview($0)
        }
        
        [recordButton, goBackward5Button, startButton, goforward5Button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            playButtonHorizontalStackView.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        slider.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        playButtonHorizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        playButtonHorizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        verticalStackView.bottomAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        verticalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
    }
}
