//
//  ViewController.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/06/29.
//

import UIKit

class CreateAudioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    private lazy var playButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordingButton, rewindButton, playPauseButton, forwardButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapRecordingButton), for: .touchDown)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("시작", for: .normal)
        button.setTitle("중지", for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var rewindButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(tapPlayPauseButton), for: .touchDown)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func config(){
        view.addSubview(playButtonStackView)
        playButtonStackView.addSubview(recordingButton)
        playButtonStackView.addSubview(rewindButton)
        playButtonStackView.addSubview(playPauseButton)
        playButtonStackView.addSubview(forwardButton)
        
        NSLayoutConstraint.activate([
            playButtonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.3),
            playButtonStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButtonStackView.heightAnchor.constraint(equalToConstant: 50),
            playButtonStackView.widthAnchor.constraint(equalToConstant: 200),
            
            recordingButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            rewindButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            forwardButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
        ])
    }
    
    @objc private func tapRecordingButton(state: UIControl.State) {
        if recordingButton.isSelected{
            recordingButton.isSelected = false
            playPauseButton.isEnabled = true
            rewindButton.isEnabled = true
            forwardButton.isEnabled = true
        }else{
            recordingButton.isSelected = true
            playPauseButton.isEnabled = false
            rewindButton.isEnabled = false
            forwardButton.isEnabled = false
        }
    }
    @objc private func tapPlayPauseButton(state: UIControl.State) {
    }
}
