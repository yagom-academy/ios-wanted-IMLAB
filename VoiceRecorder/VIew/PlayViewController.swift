//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/28.
//

import UIKit
import Combine

class PlayViewController: UIViewController {
    
    var audio: Audio? {
        didSet {
            titleLabel.text = audio?.title
            guard let url = audio?.url else { return }
            downloadAudioAndRemoveAndMoveFile(url)
        }
    }
    
    private var viewModel: PlayViewModel?
    private var cancellable = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let progressTimeView = ProgressTimeView()
    
    private let playSeekStackView = PlaySeekStackView()
    
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
        let stackView = UIStackView(arrangedSubviews: [minVolumeImageView, volumeSlider, maxVolumeImageView])
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
        
        configure()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel?.allStop()
        viewModel = nil
    }
}

// MARK: - Private

private extension PlayViewController {
    
    // MARK: - Configure UI
    
    func configure() {
        configureView()
        addSubViews()
        makeConstraints()
        addTargets()
    }
    
    func configureView() {
        view.backgroundColor = .white
    }
    
    func addSubViews() {
        [titleLabel, progressTimeView, playSeekStackView, volumeStackView, pitchSegmentedControl].forEach {
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [titleLabel, progressTimeView, playSeekStackView, volumeStackView, pitchSegmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32.0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            
            progressTimeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.0),
            progressTimeView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressTimeView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressTimeView.heightAnchor.constraint(equalToConstant: 32.0),
            
            playSeekStackView.topAnchor.constraint(equalTo: progressTimeView.bottomAnchor, constant: 32.0),
            playSeekStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            playSeekStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            volumeStackView.topAnchor.constraint(equalTo: playSeekStackView.bottomAnchor, constant: 32.0),
            volumeStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            volumeStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            pitchSegmentedControl.topAnchor.constraint(equalTo: volumeStackView.bottomAnchor, constant: 32.0),
            pitchSegmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            pitchSegmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    func addTargets() {
        playSeekStackView.backwardButton.addTarget(self, action: #selector(touchBackwardButton), for: .touchUpInside)
        playSeekStackView.forwardButton.addTarget(self, action: #selector(touchForwardButton), for: .touchUpInside)
        playSeekStackView.playPauseButton.addTarget(self, action: #selector(touchPlayPauseButton), for: .touchUpInside)
    }
    
    // MARK: - objc func
    
    @objc func touchPlayPauseButton() {
        viewModel?.togglePlaying()
    }
    
    @objc func touchBackwardButton() {
        viewModel?.skip(forwards: false)
    }
    
    @objc func touchForwardButton() {
        viewModel?.skip(forwards: true)
    }
    
    @objc func volumeSliderValueChanged(_ sender: UISlider) {
        viewModel?.volumeChanged(sender.value)
    }
    
    @objc func pitchSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let pitches: [Double] = [0, 0.5, -0.5]
        let value = pitches[sender.selectedSegmentIndex]
        viewModel?.pitchControlValueChanged(Float(value))
    }
    
    // MARK: - 기능 구현
    
    func downloadAudioAndRemoveAndMoveFile(_ url: URL) {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentURL.appendingPathComponent("Record.m4a")
        
        URLSession.shared.downloadTask(with: url) { [weak self] localUrl, response, error in
            guard let localUrl = localUrl, error == nil else { return }
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.moveItem(at: localUrl, to: fileURL)
                
                self?.viewModel = PlayViewModel(url: fileURL)
                self?.bind()
            } catch {
                print("FileManager Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func bind() {
        viewModel?.$playerProgress
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.progressTimeView.progressView.progress = value
            }
            .store(in: &cancellable)
        
        viewModel?.$playerIsPlaying
            .receive(on: DispatchQueue.main)
            .sink { isPlaying in
                if isPlaying {
                    self.playSeekStackView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                } else {
                    self.playSeekStackView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
            }
            .store(in: &cancellable)
        
        viewModel?.$playerTime
            .receive(on: DispatchQueue.main)
            .sink { playerTime in
                self.progressTimeView.playTimeLabel.text = playerTime.elapsedText
                self.progressTimeView.playTimeRemainLabel.text = playerTime.remainingText
            }
            .store(in: &cancellable)
    }
}
