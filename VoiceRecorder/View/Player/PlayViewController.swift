//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/28.
//

import UIKit
import Combine

class PlayViewController: UIViewController {
    // TODO: 이것도 변수로 전달하지 말고 수정
    var audio: Audio? {
        didSet {
            titleLabel.text = audio?.title
            guard let url = audio?.url else { return }
            downloadAudioAndMove(url)
        }
    }
    
    private var viewModel: PlayViewModel?
    private var cancellable = Set<AnyCancellable>()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "microphone")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let progressTimeView = ProgressTimeView()
    
    private lazy var pitchSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["일반 목소리", "아기 목소리", "할아버지 목소리"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(pitchSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
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
        slider.setValue(0.5, animated: false)
        slider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minVolumeImageView, volumeSlider, maxVolumeImageView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, progressTimeView, pitchSegmentedControl, playSeekStackView, volumeStackView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
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
        configureDelegate()
        addSubViews()
        makeConstraints()
    }
    
    func configureView() {
        view.backgroundColor = .white
    }
    
    func configureDelegate() {
        playSeekStackView.delegate = self
    }
    
    func addSubViews() {
        [imageView, contentStackView].forEach {
            view.addSubview($0)
        }
    }
    
    func makeConstraints() {
        [imageView, contentStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / 2),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32.0),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32.0),
            contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
        ])
    }
    
    // MARK: - objc func
    
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
                self.progressTimeView.configureProgressValue(value)
            }
            .store(in: &cancellable)
        
        viewModel?.$playerIsReady
            .receive(on: DispatchQueue.main)
            .sink { isReady in
                self.playSeekStackView.isReady(isReady)
            }
            .store(in: &cancellable)
        
        viewModel?.$playerIsPlaying
            .receive(on: DispatchQueue.main)
            .sink { isPlaying in
                self.playSeekStackView.configurePlayPauseButtonState(isPlaying)
            }
            .store(in: &cancellable)
        
        viewModel?.$playerTime
            .receive(on: DispatchQueue.main)
            .sink { playerTime in
                self.progressTimeView.configureTimeText(playerTime)
            }
            .store(in: &cancellable)
    }
}

// MARK: - PlaySeekStackViewDelegate

extension PlayViewController: PlaySeekStackViewDelegate {
    func touchBackwardButton() {
        viewModel?.skip(forwards: false)
    }
    
    func touchForwardButton() {
        viewModel?.skip(forwards: true)
    }
    
    func touchPlayPauseButton() {
        viewModel?.togglePlaying()
    }
}
