//
//  PlayView.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayView: UIView, ViewPresentable {

    let titleLabel: UILabel = {

        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    let waveLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    let audioWaveScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGray6
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let audioWaveImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    let segmentedContoller: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["일반 목소리","아기 목소리","할아버지 목소리"])
        return segment
    }()

    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.text = "volume"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let slider : UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        return slider
    }()
    
    private let playButtonHorizontalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    let startButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()
    
    let goforward5Button:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        return button
    }()
    
    let goBackrward5Button:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        audioWaveImageView.translatesAutoresizingMaskIntoConstraints = false
        audioWaveScrollView.addSubview(audioWaveImageView)

        [titleLabel, audioWaveScrollView, verticalStackView, volumeLabel, waveLineView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    
        [segmentedContoller, slider, playButtonHorizontalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview($0)
        }
        
        [goBackrward5Button, startButton, goforward5Button].forEach {
            playButtonHorizontalStackView.addArrangedSubview($0)
        }
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            audioWaveScrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            audioWaveScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            audioWaveScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            audioWaveScrollView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            
            waveLineView.heightAnchor.constraint(equalTo: audioWaveScrollView.heightAnchor),
            waveLineView.widthAnchor.constraint(equalToConstant: 1),
            waveLineView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            waveLineView.centerYAnchor.constraint(equalTo: audioWaveScrollView.centerYAnchor),
            
            audioWaveImageView.leadingAnchor.constraint(equalTo: audioWaveScrollView.centerXAnchor),
            audioWaveImageView.trailingAnchor.constraint(equalTo: audioWaveScrollView.trailingAnchor),
            audioWaveImageView.topAnchor.constraint(equalTo: audioWaveScrollView.topAnchor),
            audioWaveImageView.bottomAnchor.constraint(equalTo: audioWaveScrollView.bottomAnchor),
            
            slider.leadingAnchor.constraint(equalTo: segmentedContoller.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: segmentedContoller.trailingAnchor),
            
            volumeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            volumeLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: 7),
            
            playButtonHorizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor),
            playButtonHorizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor),
            
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80)
        ])
    }
}
