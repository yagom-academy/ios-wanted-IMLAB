//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/28.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {
    
    var audio: Audio? {
        didSet {
            guard let url = audio?.url else { return }
            let playerItem = AVPlayerItem(url: url)
            self.avPlayer = AVPlayer(playerItem: playerItem)
            self.avPlayer.volume = self.volumeSize
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.fileFormat
                self.audioFile = audioFile
                
                self.audioEngine.attach(playerNode)
                self.audioEngine.attach(pitchControl)
                self.audioEngine.connect(playerNode, to: pitchControl, format: format)
                self.audioEngine.connect(pitchControl, to: self.audioEngine.mainMixerNode, format: format)
                self.audioEngine.prepare()
                
                do {
                    try self.audioEngine.start()
                } catch let error {
                    print("audioEngineError: \(error.localizedDescription)")
                }
            } catch let error {
                print("audioFileError:\(error.localizedDescription)")
            }
            
        }
    }
    
//    var pitchIndex: Int = 1 {
//        didSet {
//            print(pitchIndex)
//            let value = allPlaybackPitches[pitchIndex]
//            self.pitchControl.pitch = 1200 * Float(value)
//        }
//    }
    
    let allPlaybackPitches: [Double] = [-0.5, 0, 0.5]
    
    private var avPlayer = AVPlayer()
    private let volumeSize: Float = 0.5
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchControl = AVAudioUnitTimePitch()
    private var audioFile: AVAudioFile?
    
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
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        slider.setValue(self.volumeSize, animated: false)
        return slider
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.volumeLabel, self.volumeSlider])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var pitchSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["일반 목소리", "아기 목소리", "할아버지 목소리"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(pitchSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
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
        [self.buttonStackView, self.volumeStackView, self.pitchSegmentedControl].forEach {
            self.view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [self.buttonStackView, self.volumeStackView, self.pitchSegmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            self.buttonStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32.0),
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32.0),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0),
            
            self.volumeStackView.topAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor, constant: 32.0),
            self.volumeStackView.leadingAnchor.constraint(equalTo: self.buttonStackView.leadingAnchor),
            self.volumeStackView.trailingAnchor.constraint(equalTo: self.buttonStackView.trailingAnchor),
            
            self.pitchSegmentedControl.topAnchor.constraint(equalTo: self.volumeStackView.bottomAnchor, constant: 32.0),
            self.pitchSegmentedControl.leadingAnchor.constraint(equalTo: self.buttonStackView.leadingAnchor),
            self.pitchSegmentedControl.trailingAnchor.constraint(equalTo: self.buttonStackView.trailingAnchor),
        ])
    }
    
    @objc func touchPlayPauseButton() {
        switch self.avPlayer.timeControlStatus {
        case .playing:
            self.avPlayer.pause()
            self.playPauseButton.isSelected.toggle()
        case .paused:
            self.avPlayer.play()
            self.playPauseButton.isSelected.toggle()
        default: break
        }
    }
    
    @objc func touchBackwardButton() {
        let currentTime = self.avPlayer.currentTime()
        let time = CMTime(value: 5, timescale: 1)
        self.avPlayer.seek(to: currentTime - time)
    }
    
    @objc func touchForwardButton() {
        let currentTime = self.avPlayer.currentTime()
        let time = CMTime(value: 5, timescale: 1)
        self.avPlayer.seek(to: currentTime + time)
    }
    
    @objc func volumeSliderValueChanged(_ sender: UISlider) {
        self.avPlayer.volume = sender.value
    }
    
    @objc func pitchSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let value = allPlaybackPitches[sender.selectedSegmentIndex]
        print(value)
        self.pitchControl.pitch = 1200 * Float(value)
    }
}
