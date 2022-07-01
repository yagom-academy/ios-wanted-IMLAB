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
    
    private var viewModel: PlayViewModel?
    
//    init(viewModel: PlayViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
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
        return UIButton().playControlButton("play.fill","pause.fill", state: .normal,.selected)
//        let button = UIButton().playControlButton("play.fill", state: .normal)
//        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
//        return button
//
//        let button = UIButton(type: .custom)
//        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
//        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 32.0), forImageIn: .normal)
//        button.addTarget(self, action: #selector(touchPlayPauseButton), for: .touchUpInside)
//        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.backwardButton, self.playPauseButton, self.forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let minVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "speaker.fill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let maxVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "speaker.3.fill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        slider.setValue(1.0, animated: false)
        return slider
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.minVolumeImageView, self.volumeSlider, self.maxVolumeImageView])
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
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        self.audioEngine = nil
//    }
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
        [self.titleLabel, self.buttonStackView, self.progressView,
         self.volumeStackView, self.pitchSegmentedControl].forEach {
            self.view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [self.titleLabel, self.buttonStackView, self.progressView,
         self.volumeStackView, self.pitchSegmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32.0),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32.0),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0),
            
            self.progressView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 32.0),
            self.progressView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.progressView.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            
            self.buttonStackView.topAnchor.constraint(equalTo: self.progressView.bottomAnchor, constant: 32.0),
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
        self.viewModel?.togglePlaying { success in
            if success {
                self.playPauseButton.isSelected.toggle()
            }
        }
    }
    
    @objc func touchBackwardButton() {
        self.viewModel?.skip(forwards: false)
    }
    
    @objc func touchForwardButton() {
        self.viewModel?.skip(forwards: true)
    }
    
    @objc func volumeSliderValueChanged(_ sender: UISlider) {
        self.viewModel?.volumeChanged(sender.value)
    }
    
    @objc func pitchSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let pitches: [Double] = [0, 0.5, -0.5]
        let value = pitches[sender.selectedSegmentIndex]
        self.viewModel?.pitchControlValueChanged(Float(value))
    }
    
    // MARK: - Configure AVAudioEngine
    
    func setAudio(_ url: URL) {
        // 파일에 항상 같은 이름으로 저장
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent("Record.m4a")
        
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            guard let localUrl = localUrl, error == nil else { return }
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.moveItem(at: localUrl, to: fileURL)
                
                self.viewModel = PlayViewModel(url: fileURL)
                self.bind()
            } catch {
                print("FileManager Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func bind() {
        viewModel?.playerProgress.observe(on: self) { [weak self] playerProgress in
            DispatchQueue.main.async {
                self?.progressView.progress = playerProgress
            }
        }
    }
}
