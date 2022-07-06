//
//  PlayView.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayView: UIView, ViewPresentable {
    
    private let segmentedContoller: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["일반 목소리","아기 목소리","할아버지 목소리"])
        return segment
    }()
    
    private let goforward5Button:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        return button
    }()
    
    private let goBackrward5Button:UIButton = {
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
        stackView.spacing = 20
         stackView.distribution = .fillEqually
         stackView.axis = .vertical
         stackView.alignment = .center
         return stackView
    }()
    
    private let startButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()
    
    private let slider : UISlider = {
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
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(verticalStackView)
        
        [segmentedContoller,slider,playButtonHorizontalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview($0)
        }
    
        [goBackrward5Button,startButton,goforward5Button].forEach {
            playButtonHorizontalStackView.addArrangedSubview($0)
        }
        

    }
    
    func setupConstraints() {
        
        slider.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true

        playButtonHorizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
        playButtonHorizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor).isActive = true
        
        verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80).isActive = true
    }
}
