//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/28.
//

import UIKit
import AVFAudio

class PlayViewController: UIViewController {
    
    var audio: Audio? {
        didSet {
            guard let url = audio?.url else { return }
            var data: Data?
            
            do {
                data = try Data(contentsOf: url)
            } catch let error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                audioPlayer = try AVAudioPlayer(data: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 32.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(touchBackwardButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 32.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(touchForwardButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 32.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(touchPlayPauseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.backwardButton, self.playPauseButton, self.forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.text = "볼륨 조절"
        return label
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.volumeLabel, self.volumeSlider])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configure()
    }
}

private extension PlayViewController {
    func configure() {
        self.configureView()
        self.addSubViews()
        self.makeConstraints()
    }
    
    func configureView() {
        self.view.backgroundColor = .white
    }
    
    func addSubViews() {
        [self.buttonStackView, self.volumeStackView].forEach {
            self.view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [self.buttonStackView, self.volumeStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            self.buttonStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0),
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32.0),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0),
            
            self.volumeStackView.topAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor, constant: 16.0),
            self.volumeStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32.0),
            self.volumeStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0),
        ])
    }
    
    @objc func touchPlayPauseButton() {
        if self.audioPlayer?.isPlaying == false {
            self.audioPlayer?.play()
            self.playPauseButton.isSelected.toggle()
        } else {
            self.audioPlayer?.stop()
            self.playPauseButton.isSelected.toggle()
        }
    }
    
    @objc func touchBackwardButton() {
    }
    
    @objc func touchForwardButton() {
    }
}
