//
//  VoiceMemoPlayViewController.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/06/28.
//

import UIKit

class VoiceMemoPlayViewController: UIViewController {
    
    // MARK: - Properties
    
    private var audioFileName: String?
    private weak var audioManager: AudioManager!
    private weak var pathFinder: PathFinder!
    private weak var firebaseManager: FirebaseStorageManager!
    
    private var grayTransparentViewWidthConstant: NSLayoutConstraint!
    
    // MARK: - ViewProperties
    
    private let titleLabel: UILabel = {
        
        let label = UILabel()
        return label
    }()
    
    private let waveFormView: WaveFormView = {
        
        let view = WaveFormView(frame: .zero)
        view.waveFormViewMode = .play
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let pitchSegmentedController: UISegmentedControl = {
        
        let segmentItems = ["일반 목소리", "아기 목소리", " 할아버지 목소리"]
        let segment = UISegmentedControl(items: segmentItems)
        segment.selectedSegmentIndex = 0
        segment.addTarget(nil, action: #selector(pitchChangeSegmentedControllerTouched(_:)), for: .valueChanged)
        return segment
    }()
    
    private let volumeLabel: UILabel = {
        
        let label = UILabel()
        label.text = "volume"
        return label
    }()
    
    private let volumeSlider: UISlider = {
        
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.setValue(0.5, animated: false)
        slider.isContinuous = true
        slider.addTarget(nil, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private let playOrPauseButton: UIButton = {
        
        let playIcon = UIImage(systemName: "play")
        let pauseIcon = UIImage(systemName: "pause.fill")
        let symbolConfigure = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .default)
        let button = UIButton()
        
        button.setImage(playIcon, for: .normal)
        button.setImage(pauseIcon, for: .selected)
        button.setPreferredSymbolConfiguration(symbolConfigure, forImageIn: .normal)
        button.setPreferredSymbolConfiguration(symbolConfigure, forImageIn: .selected)
        button.addTarget(nil, action: #selector(playOrPauseButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let skipBackward5SecondButton: UIButton = {
        
        let image = UIImage(systemName: "gobackward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        button.addTarget(nil, action: #selector(skip5SecondsButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let skipForward5SecondButton: UIButton = {
        
        let image = UIImage(systemName: "goforward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        button.addTarget(nil, action: #selector(skip5SecondsButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let playButtonStackView: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 30
        return stack
    }()
    
    private let grayTransparentView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .systemGray2
        view.alpha = 0.7
        return view
    }()
    
    // MARK: - Life Cycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    init(audioFileName: String,
         audioManager: AudioManager,
         pathFinder: PathFinder,
         firebaseManager: FirebaseStorageManager) {
        
        self.audioFileName = audioFileName
        self.audioManager = audioManager
        self.pathFinder = pathFinder
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        designUI()
        
        audioManager.delegateMethod = modifyGrayParentViewTrailingAnchor
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlaybackTimeIsOver(_:)), name: .audioPlaybackTimeIsOver, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(true)
        audioManager.stopPlay()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        guard let audioFileName =  audioFileName else {
            return
        }
        let filePath = pathFinder.getPath(fileName: audioFileName)
        guard let bufferDatas = audioManager
            .calculateBufferGraphData(width: waveFormView.bounds.width, filePath: filePath) else {
            return
        }
        
        waveFormView.waveforms = bufferDatas
    }
    
}

// MARK: - Objc Method

extension VoiceMemoPlayViewController {
    
    @objc private func playOrPauseButtonTouched(_ sender: UIButton) {
        
        guard let audioFileName = audioFileName else {
            return
        }
        
        let path = pathFinder.getPath(fileName: audioFileName)
        
        DispatchQueue.main.async { [unowned self] in
            
            sender.isSelected.toggle()
            if sender.isSelected {
                audioManager.startPlay(fileURL: path)
            } else {
                audioManager.stopPlay()
            }
        }
    }
    
    @objc private func skip5SecondsButtonTouched(_ sender: UIButton) {
        
        if sender === skipForward5SecondButton {
            audioManager.skip(for: 5, filePath: pathFinder.lastUsedUrl)
        } else {
            audioManager.skip(for: -5, filePath: pathFinder.lastUsedUrl)
        }
    }
    
    @objc private func pitchChangeSegmentedControllerTouched(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            audioManager.pitchMode = .basic
        case 1:
            audioManager.pitchMode = .baby
        case 2:
            audioManager.pitchMode = .grandFather
        default:
            audioManager.pitchMode = .basic
        }
    }
    
    @objc private func sliderValueDidChange(_ sender: UISlider) {
        
        audioManager.controlVolume(newValue: sender.value)
    }
    
    @objc private func audioPlaybackTimeIsOver(_ sender: NSNotification) {
        
        playOrPauseButtonTouched(playOrPauseButton)
    }
    
}

// MARK: - GrayParentView Delegate

extension VoiceMemoPlayViewController {
    
    private func modifyGrayParentViewTrailingAnchor(ratio: Float) {
        
        DispatchQueue.main.async { [unowned self] in
            
            let waveViewWidth = waveFormView.bounds.width
            let incresingWidth: CGFloat = waveViewWidth * CGFloat(ratio)
            grayTransparentViewWidthConstant.constant = incresingWidth
            
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

// MARK: - UI Design

extension VoiceMemoPlayViewController {
    
    private func configureSubViews() {
        
        [titleLabel, waveFormView, pitchSegmentedController,
         volumeLabel, volumeSlider, playButtonStackView, grayTransparentView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [skipBackward5SecondButton, playOrPauseButton, skipForward5SecondButton].forEach {
            playButtonStackView.addArrangedSubview($0)
        }
    }
    
    private func designUI() {
        
        view.backgroundColor = .systemBackground
        configureSubViews()
        self.titleLabel.text = audioFileName ?? "PlayView"
        
        designTitleLabel()
        designVolumeLabel()
        designVolumeSlider()
        designWaveFormView()
        designGrayTransparentView()
        designPlayOrPauseButton()
        designPitchSegmentedController()
        designPlayButtonStackView()
        designSkipForward5SecondButton()
        designSkipBackward5SecondButton()
    }
    
    private func designTitleLabel() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func designWaveFormView() {
        
        NSLayoutConstraint.activate([
            waveFormView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waveFormView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            waveFormView.heightAnchor.constraint(equalToConstant: 80),
            waveFormView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            waveFormView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func designGrayTransparentView() {
        
        grayTransparentViewWidthConstant = grayTransparentView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            grayTransparentView.heightAnchor.constraint(equalTo: waveFormView.heightAnchor),
            grayTransparentView.topAnchor.constraint(equalTo: waveFormView.topAnchor),
            grayTransparentView.centerYAnchor.constraint(equalTo: waveFormView.centerYAnchor),
            grayTransparentView.leadingAnchor.constraint(equalTo: waveFormView.leadingAnchor),
            grayTransparentViewWidthConstant
        ])
    }
    
    private func designPitchSegmentedController() {
        
        NSLayoutConstraint.activate([
            pitchSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pitchSegmentedController.topAnchor.constraint(equalTo: waveFormView.bottomAnchor, constant: 80),
            pitchSegmentedController.widthAnchor.constraint(equalTo: waveFormView.widthAnchor),
            pitchSegmentedController.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func designVolumeLabel() {
        
        NSLayoutConstraint.activate([
            volumeLabel.leadingAnchor.constraint(equalTo: pitchSegmentedController.leadingAnchor),
            volumeLabel.topAnchor.constraint(equalTo: pitchSegmentedController.bottomAnchor, constant: 25)
        ])
    }
    
    private func designVolumeSlider() {
        
        NSLayoutConstraint.activate([
            volumeSlider.widthAnchor.constraint(equalTo: waveFormView.widthAnchor),
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 15)
        ])
    }
    
    private func designPlayButtonStackView() {
        
        NSLayoutConstraint.activate([
            playButtonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButtonStackView.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 35)
        ])
    }
    
    private func designPlayOrPauseButton() {
        
        NSLayoutConstraint.activate([
            playOrPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playOrPauseButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func designSkipForward5SecondButton() {
        
        NSLayoutConstraint.activate([
            skipForward5SecondButton.widthAnchor.constraint(equalTo: playOrPauseButton.widthAnchor),
            skipForward5SecondButton.heightAnchor.constraint(equalTo: playOrPauseButton.heightAnchor)
        ])
    }
    
    private func designSkipBackward5SecondButton() {
        
        NSLayoutConstraint.activate([
            skipBackward5SecondButton.widthAnchor.constraint(equalTo: playOrPauseButton.widthAnchor),
            skipBackward5SecondButton.heightAnchor.constraint(equalTo: playOrPauseButton.heightAnchor)
        ])
    }
}
