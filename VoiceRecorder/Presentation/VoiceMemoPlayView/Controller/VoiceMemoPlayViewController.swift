//
//  VoiceMemoPlayViewController.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/06/28.
//

import UIKit

class VoiceMemoPlayViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let voiceMemoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "2022.05.08 12:34:56"
        
        return label
    }()
    
    private let waveFormView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        
        return view
    }()
    
    private let voiceSegment: UISegmentedControl = {
        let segmentItems = ["일반 목소리", "아기 목소리", " 할아버지 목소리"]
        let segment = UISegmentedControl(items: segmentItems)
        segment.selectedSegmentIndex = 0
        
        return segment
    }()
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.text = "volume"
        
        return label
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.setValue(0.5, animated: false)
        
        return slider
    }()
    
    private let playAndStopButon: UIButton = {
        let image = UIImage(systemName: "play")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        
        return button
    }()
    
    private let goBackwardFiveSecondButton: UIButton = {
        let image = UIImage(systemName: "gobackward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        
        return button
    }()
    
    private let goForwardFiveSecondButton: UIButton = {
        let image = UIImage(systemName: "goforward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        
        return button
    }()
    
    let playButtonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 30
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSubViews()
        configureConstraints()
    }
    
    // MARK: - Method
    private func configureSubViews() {
        [voiceMemoTitleLabel, waveFormView, voiceSegment,
         volumeLabel, volumeSlider, playButtonStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [goBackwardFiveSecondButton, playAndStopButon, goForwardFiveSecondButton].forEach {
            playButtonStackView.addArrangedSubview($0)
        }
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            voiceMemoTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            voiceMemoTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            waveFormView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waveFormView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            waveFormView.heightAnchor.constraint(equalToConstant: 80),
            waveFormView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            waveFormView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            voiceSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            voiceSegment.topAnchor.constraint(equalTo: waveFormView.bottomAnchor, constant: 80),
            voiceSegment.widthAnchor.constraint(equalTo: waveFormView.widthAnchor),
            voiceSegment.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            volumeLabel.leadingAnchor.constraint(equalTo: voiceSegment.leadingAnchor),
            volumeLabel.topAnchor.constraint(equalTo: voiceSegment.bottomAnchor, constant: 25)
        ])
        
        NSLayoutConstraint.activate([
            volumeSlider.widthAnchor.constraint(equalTo: waveFormView.widthAnchor),
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 15)
        ])
        
        NSLayoutConstraint.activate([
            playButtonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButtonStackView.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 35)
        ])
        
        NSLayoutConstraint.activate([
            playAndStopButon.widthAnchor.constraint(equalToConstant: 40),
            playAndStopButon.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            goForwardFiveSecondButton.widthAnchor.constraint(equalTo: playAndStopButon.widthAnchor),
            goForwardFiveSecondButton.heightAnchor.constraint(equalTo: playAndStopButon.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            goBackwardFiveSecondButton.widthAnchor.constraint(equalTo: playAndStopButon.widthAnchor),
            goBackwardFiveSecondButton.heightAnchor.constraint(equalTo: playAndStopButon.heightAnchor)
        ])
    }
}
