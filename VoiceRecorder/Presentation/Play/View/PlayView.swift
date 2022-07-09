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
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.text = "volume"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let segmentedContoller: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["일반 목소리","아기 목소리","할아버지 목소리"])
        return segment
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
    
    private let playButtonHorizontalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    let startButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()
    
    let slider : UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        return slider
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
        addSubview(volumeLabel)
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel,verticalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        [segmentedContoller,slider,playButtonHorizontalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview($0)
        }
        
        [goBackrward5Button,startButton,goforward5Button].forEach {
            playButtonHorizontalStackView.addArrangedSubview($0)
        }
        
    }
    
    func setupConstraints() {
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        slider.leadingAnchor.constraint(equalTo: segmentedContoller.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: segmentedContoller.trailingAnchor).isActive = true
        
        volumeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor).isActive = true
        volumeLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: 7).isActive = true
        
        playButtonHorizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        playButtonHorizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80).isActive = true
    }
}
