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
            playContentView.titleLabel.text = audio?.title
            guard let url = audio?.url else { return }
            downloadAudioAndMove(url)
        }
    }
    
    private var viewModel: PlayViewModel?
    private var cancellable = Set<AnyCancellable>()
    
    private let playImageView = PlayImageView()
    private let playContentView = PlayContentView()
    
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
        [playImageView, playContentView].forEach {
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [playImageView, playContentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            playImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            playImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            playImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            playContentView.topAnchor.constraint(equalTo: playImageView.bottomAnchor),
            playContentView.leadingAnchor.constraint(equalTo: playImageView.leadingAnchor),
            playContentView.trailingAnchor.constraint(equalTo: playImageView.trailingAnchor),
            playContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func addTargets() {
        playContentView.playSeekStackView.backwardButton.addTarget(self, action: #selector(touchBackwardButton), for: .touchUpInside)
        playContentView.playSeekStackView.forwardButton.addTarget(self, action: #selector(touchForwardButton), for: .touchUpInside)
        playContentView.playSeekStackView.playPauseButton.addTarget(self, action: #selector(touchPlayPauseButton), for: .touchUpInside)
        playContentView.volumeSlider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        playContentView.pitchSegmentedControl.addTarget(self, action: #selector(pitchSegmentedControlValueChanged(_:)), for: .valueChanged)
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
        viewModel?.pitchControlValueChanged(sender.selectedSegmentIndex)
    }
    
    // MARK: - 기능 구현
    
    func downloadAudioAndMove(_ url: URL) {
        NetworkManager.shared.downloadAudioAndMove(url) { [weak self] result in
            switch result {
            case .success(let url):
                self?.viewModel = PlayViewModel(url: url)
                self?.bind()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func bind() {
        viewModel?.$playerProgress
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.playContentView.progressTimeView.progressView.progress = value
            }
            .store(in: &cancellable)
        
        viewModel?.$playerIsReady
            .receive(on: DispatchQueue.main)
            .sink { isReady in
                self.playContentView.playSeekStackView.backwardButton.isEnabled = isReady ? true : false
                self.playContentView.playSeekStackView.playPauseButton.isEnabled = isReady ? true : false
                self.playContentView.playSeekStackView.forwardButton.isEnabled = isReady ? true : false
            }
            .store(in: &cancellable)
        
        viewModel?.$playerIsPlaying
            .receive(on: DispatchQueue.main)
            .sink { isPlaying in
                if isPlaying {
                    self.playContentView.playSeekStackView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                } else {
                    self.playContentView.playSeekStackView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
            }
            .store(in: &cancellable)
        
        viewModel?.$playerTime
            .receive(on: DispatchQueue.main)
            .sink { playerTime in
                self.playContentView.progressTimeView.playTimeLabel.text = playerTime.elapsedText
                self.playContentView.progressTimeView.playTimeRemainLabel.text = playerTime.remainingText
            }
            .store(in: &cancellable)
    }
}
