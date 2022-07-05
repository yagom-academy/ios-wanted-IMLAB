//
//  VoiceMemoPlayViewController.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/06/28.
//

import UIKit

class VoiceMemoPlayViewController: UIViewController {
    
    // - MARK: Properties
    
    private var audioFileName: String?
    private weak var audioManager: AudioManager!
    private weak var pathFinder: PathFinder!
    private weak var firebaseManager: FirebaseStorageManager!
    
    // MARK: - ViewProperties
    private let voiceMemoTitleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let waveFormView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        
        return view
    }()
    
    private let voiceSegment: UISegmentedControl = {
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
    
    private let playOrStopButon: UIButton = {
        let playIcon = UIImage(systemName: "play")
        let pauseIcon = UIImage.init(systemName: "pause.fill")
        
        let symbolConfigure: UIImage.SymbolConfiguration = .init(pointSize: 35, weight: .regular, scale: .default)
        
        let button = UIButton()
        
        button.setImage(playIcon, for: .normal)
        button.setImage(pauseIcon, for: .selected)
        
        button.setPreferredSymbolConfiguration(symbolConfigure, forImageIn: .normal)
        button.setPreferredSymbolConfiguration(symbolConfigure, forImageIn: .selected)
        
        button.addTarget(nil, action: #selector(playOrStopButtonTouched(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private let skipBackward5SecondButton: UIButton = {
        let image = UIImage(systemName: "gobackward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        
        button.addTarget(nil, action: #selector(skipForward5SecButtonTouched(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private let skipForward5SecondButton: UIButton = {
        let image = UIImage(systemName: "goforward.5")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        
        button.addTarget(nil, action: #selector(skipForward5SecButtonTouched(_:)), for: .touchUpInside)
        
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
        view.backgroundColor = .systemGray6
        view.alpha = 0.7
        
        return view
    }()
    
    // - MARK: Objc Selector Event Method
    
    @objc func playOrStopButtonTouched(_ sender: UIButton) {
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
    
    @objc func skipForward5SecButtonTouched(_ sender: UIButton) {
        audioManager.skip(for: 5, filePath: pathFinder.lastUsedUrl)
    }
    
    @objc func skipBackward5SecButtonTouched(_ sender: UIButton) {
        audioManager.skip(for: -5, filePath: pathFinder.lastUsedUrl)
    }
    
    @objc func pitchChangeSegmentedControllerTouched(_ sender: UISegmentedControl) {
        
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
    
    @objc func sliderValueDidChange(_ sender: UISlider) {
        audioManager.controlVolume(newValue: sender.value)
    }
    
    @objc func audioPlaybackTimeIsOver(_ sender: NSNotification) {
        playOrStopButtonTouched(playOrStopButon)
    }
    
    // - MARK: Life Cycle
    
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
        view.backgroundColor = .systemBackground
        configureSubViews()
        configureConstraints()
        
        self.voiceMemoTitleLabel.text = audioFileName ?? "PlayView"
        
        audioManager.delegateMethod = modifyGrayParentViewTrailingAnchor
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlaybackTimeIsOver(_:)), name: .audioPlaybackTimeIsOver, object: nil)
    }
    
}

// MARK: - GrayParentView Delegate

extension VoiceMemoPlayViewController {
    func modifyGrayParentViewTrailingAnchor(ratio: Float) {
        DispatchQueue.main.async { [unowned self] in
            
            let waveViewWidth = waveFormView.bounds.width
            
            let incresingWidth: CGFloat = waveViewWidth * CGFloat(ratio)
            print(ratio,incresingWidth)
            grayTransparentView.widthAnchor.constraint(equalToConstant: incresingWidth).isActive = true
            
            view.layoutIfNeeded()
        }
    }
}

// MARK: - UI Design

extension VoiceMemoPlayViewController {
    
    private func configureSubViews() {
        [voiceMemoTitleLabel, waveFormView, voiceSegment,
         volumeLabel, volumeSlider, playButtonStackView, grayTransparentView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [skipBackward5SecondButton, playOrStopButon, skipForward5SecondButton].forEach {
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
            grayTransparentView.heightAnchor.constraint(equalTo: waveFormView.heightAnchor),
            grayTransparentView.topAnchor.constraint(equalTo: waveFormView.topAnchor),
            grayTransparentView.centerYAnchor.constraint(equalTo: waveFormView.centerYAnchor),
            grayTransparentView.leadingAnchor.constraint(equalTo: waveFormView.leadingAnchor)
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
            playOrStopButon.widthAnchor.constraint(equalToConstant: 40),
            playOrStopButon.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            skipForward5SecondButton.widthAnchor.constraint(equalTo: playOrStopButon.widthAnchor),
            skipForward5SecondButton.heightAnchor.constraint(equalTo: playOrStopButon.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            skipBackward5SecondButton.widthAnchor.constraint(equalTo: playOrStopButon.widthAnchor),
            skipBackward5SecondButton.heightAnchor.constraint(equalTo: playOrStopButon.heightAnchor)
        ])
    }
}
