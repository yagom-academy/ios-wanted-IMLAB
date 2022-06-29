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
            self.titleLabel.text = audio?.title
            guard let url = audio?.url else { return }
            self.setAudio(url)
        }
    }
    
    private let volumeSize: Float = 0.5
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchControl = AVAudioUnitTimePitch()
    private var audioFile: AVAudioFile?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
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
    
    // MARK: - Configure UI
    
    func configure() {
        self.configureView()
        self.addSubViews()
        self.makeConstraints()
    }
    
    func configureView() {
        self.view.backgroundColor = .white
    }
    
    func addSubViews() {
        [self.titleLabel, self.buttonStackView,
         self.volumeStackView, self.pitchSegmentedControl].forEach {
            self.view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [self.titleLabel, self.buttonStackView,
         self.volumeStackView, self.pitchSegmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32.0),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32.0),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0),
            
            self.buttonStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 32.0),
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            
            self.volumeStackView.topAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor, constant: 32.0),
            self.volumeStackView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.volumeStackView.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            
            self.pitchSegmentedControl.topAnchor.constraint(equalTo: self.volumeStackView.bottomAnchor, constant: 32.0),
            self.pitchSegmentedControl.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.pitchSegmentedControl.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
        ])
    }
    
    // MARK: - objc func
    
    @objc func touchPlayPauseButton() {
        if self.playerNode.isPlaying == false {
            self.playerNode.play()
        } else {
            self.playerNode.pause()
        }
        self.playPauseButton.isSelected.toggle()
    }
    
    @objc func touchBackwardButton() {
//        let currentTime = self.avPlayer.currentTime()
//        let time = CMTime(value: 5, timescale: 1)
//        self.avPlayer.seek(to: currentTime - time)
    }
    
    @objc func touchForwardButton() {
//        let currentTime = self.avPlayer.currentTime()
//        let time = CMTime(value: 5, timescale: 1)
//        self.avPlayer.seek(to: currentTime + time)
    }
    
    @objc func volumeSliderValueChanged(_ sender: UISlider) {
        self.playerNode.volume = sender.value
    }
    
    @objc func pitchSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let pitches: [Double] = [0, 0.5, -0.5]
        let value = pitches[sender.selectedSegmentIndex]
        self.pitchControl.pitch = 1200 * Float(value)
    }
    
    // MARK: - Configure AVAudioEngine
    
    func setAudio(_ url: URL) {
        // 파일에 항상 같은 이름으로 저장
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent("Record.mp3")
        
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            guard let localUrl = localUrl, error == nil else { return }
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.moveItem(at: localUrl, to: fileURL)
                self.configureAudioFile(fileURL)
            } catch {
                print("FileManager Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func configureAudioFile(_ url: URL) {
        // local에 저장된 file의 url을 사용하여 AVAudioFile을 생성한 후 할당
        do {
            let file = try AVAudioFile(forReading: url)
            self.audioFile = file
            self.configureAudioEngine()
        } catch {
            print("AVAudioFile Error: \(error.localizedDescription)")
        }
    }
    
    func configureAudioEngine() {
        // 2: connect the components to our playback engine
        // 컴포넌트를 재생 엔진에 연결
        self.audioEngine.attach(self.playerNode)
        self.audioEngine.attach(self.pitchControl)

        // 3: arrange the parts so that output from one is input to another
        // 한 쪽의 출력이 다른쪽에 입력되도록 연결하여 정렬
        self.audioEngine.connect(self.playerNode, to: self.pitchControl, format: nil)
        self.audioEngine.connect(self.pitchControl, to: self.audioEngine.mainMixerNode, format: nil)

        // 4: prepare the player to play its file from the beginning
        // 플레이어가 파일을 재생하도록 준비
        guard let audioFile = self.audioFile else { return }
        self.playerNode.scheduleFile(audioFile, at: nil)
        self.playerNode.volume = self.volumeSize

        self.audioEngine.prepare()
        
        // 5: start the engine
        do {
            try self.audioEngine.start()
        } catch {
            print("AudioEngine Error: \(error.localizedDescription)")
        }
    }
}
