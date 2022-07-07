//
//  VoiceMemoRecordViewController.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/06/28.
//

import UIKit

class VoiceMemoRecordViewController: UIViewController {
    
    enum RecordViewJobMode {
        case record
        case play
    }
    
    // MARK: - Properties
    
    private let pathFinder: PathFinder!
    private let audioRecorder: AudioRecodable!
    private let audioPlayer: AudioPlayable!
    private let firebaseManager: FirebaseStorageManager!
    
    //  MARK: - ViewProperties
    
    private var waveFormView: WaveFormView = {
        
        let view = WaveFormView(frame: .zero)
        view.waveFormViewMode = .record
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let cutoffFrequencyLabel: UILabel = {
        
        let label = UILabel()
        label.text = "cutoff freqency"
        return label
    }()
    
    private let cutOffFrequencySlider: UISlider = {
        
        let slider = UISlider()
        slider.value = 1
        slider.addTarget(nil, action: #selector(cutOffFrequencySliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private let playTimeLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private let playOrPauseButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        button.addTarget(nil, action: #selector(playOrPauseButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let recordButton: UIButton = {
        
        let button = UIButton()
        button.tintColor = .systemRed
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.setImage(UIImage(systemName: "stop.fill"), for: .selected)
        let symbol = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .default)
        button.setPreferredSymbolConfiguration(symbol, forImageIn: .normal)
        button.addTarget(nil, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let skipForward5SecondsButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        let symbol = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .default)
        button.setPreferredSymbolConfiguration(symbol, forImageIn: .normal)
        button.addTarget(nil, action: #selector(skip5SecondsButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let skipBackward5SecondsButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        let symbol = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .default)
        button.setPreferredSymbolConfiguration(symbol, forImageIn: .normal)
        button.addTarget(nil, action: #selector(skip5SecondsButtonTouched(_:)), for: .touchUpInside)
        return button
    }()
    
    private let playButtonStackView: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 30
        
        return stack
    }()
    
    // MARK: - Life Cycle
    
    init(pathFinder: PathFinder,
         audioPlayer: AudioPlayable,
         audioRecorder: AudioRecodable,
         firebaseManager: FirebaseStorageManager) {
        
        self.pathFinder = pathFinder
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configure()
        designUI()
        hiddenPlayRelatedButtons(.record)
        presentationController?.delegate = self
        audioRecorder.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlaybackTimeIsOver(_:)), name: .audioPlaybackTimeIsOver, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        audioRecorder.stopRecord()
        audioPlayer.stopPlay()
    }
    
    private func configure() {
        
        self.view.backgroundColor = .systemBackground
    }
    
    // MARK: - UI Design
    
    private func configureSubviews() {
        
        [waveFormView, playOrPauseButton, playButtonStackView,
         cutoffFrequencyLabel, cutOffFrequencySlider, playTimeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [recordButton, skipBackward5SecondsButton, playOrPauseButton,
         skipForward5SecondsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            playButtonStackView.addArrangedSubview($0)
        }
    }
    
    private func designUI() {
        
        configureSubviews()
        desigWaveView()
        designCutOffLabel()
        designSlider()
        designPlayTimeLabel()
        designButtons()
    }
    
    private func desigWaveView() {
        
        NSLayoutConstraint.activate([
            waveFormView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.1),
            waveFormView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            waveFormView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            waveFormView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func designCutOffLabel() {
        
        NSLayoutConstraint.activate([
            cutoffFrequencyLabel.topAnchor.constraint(equalTo: waveFormView.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            cutoffFrequencyLabel.leadingAnchor.constraint(equalTo: waveFormView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cutoffFrequencyLabel.trailingAnchor.constraint(equalTo: waveFormView.safeAreaLayoutGuide.trailingAnchor,  constant: -16),
            cutoffFrequencyLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func designSlider() {
        
        NSLayoutConstraint.activate([
            cutOffFrequencySlider.topAnchor.constraint(equalTo: cutoffFrequencyLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            cutOffFrequencySlider.leadingAnchor.constraint(equalTo: cutoffFrequencyLabel.safeAreaLayoutGuide.leadingAnchor),
            cutOffFrequencySlider.trailingAnchor.constraint(equalTo: cutoffFrequencyLabel.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func designPlayTimeLabel() {
        
        NSLayoutConstraint.activate([
            playTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playTimeLabel.topAnchor.constraint(equalTo: cutOffFrequencySlider.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            playTimeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func designButtons() {
        
        NSLayoutConstraint.activate([
            playButtonStackView.topAnchor.constraint(equalTo:playTimeLabel.safeAreaLayoutGuide.bottomAnchor, constant: 35),
            playButtonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

// MARK: - Method

extension VoiceMemoRecordViewController {
    
    /// 플레이관련 버튼들의 hidden animation
    private func hiddenPlayRelatedButtons(_ mode: RecordViewJobMode) {
        
        let playRelatedButtons = [playOrPauseButton, skipBackward5SecondsButton, skipForward5SecondsButton]
        UIView.animate(withDuration: 0.05) {
            
            if mode == .record {
                playRelatedButtons.forEach { $0.isHidden = true }
            } else {
                playRelatedButtons.forEach { $0.isHidden = false }
            }
        }
    }
    
    private func convertSecondToMinute() -> String {
        
        guard let time = Int(audioRecorder.getPlayTime(filePath: pathFinder.lastUsedUrl)) else {
            return ""
        }
        
        let minute = String(format: "%02d", time / 60)
        let second = String(format: "%02d", time % 60)
        return "\(minute):\(second)"
    }
    
    private func uploadVoiceMemoToFirebaseStorage() {
        
        firebaseManager
            .uploadVoiceMemoToFirebase(with: pathFinder.lastUsedUrl,
                                       fileName: pathFinder.lastUsedFileName,
                                       playTime: audioRecorder.getPlayTime(filePath:pathFinder.lastUsedUrl)) { [weak self] result in
            
            switch result {
            case .success(_):
                self?.validateUploadFinish()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func validateUploadFinish() {
        
        NotificationCenter.default.post(name: .recordViewUploadComplete, object: nil)
    }
}

// MARK: - objc Method

extension VoiceMemoRecordViewController {
    
    @objc private func recordButtonTapped(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            waveFormView.restartWaveForm()
            playTimeLabel.text = ""
            hiddenPlayRelatedButtons(.record)
            audioRecorder.startRecord(filePath: pathFinder.getPathWithTime())
            audioPlayer.stopPlay()
        } else {
            hiddenPlayRelatedButtons(.play)
            audioRecorder.stopRecord()
            playTimeLabel.text = convertSecondToMinute()
            uploadVoiceMemoToFirebaseStorage()
        }
    }
    
    @objc private func playOrPauseButtonTouched(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            audioPlayer.startPlay(fileURL: pathFinder.lastUsedUrl)
        } else {
            audioPlayer.pausePlay()
        }
    }
    
    @objc private func skip5SecondsButtonTouched(_ sender: UIButton) {
        
        if sender === skipForward5SecondsButton {
            audioPlayer.skip(for: 5, filePath: pathFinder.lastUsedUrl)
        } else {
            audioPlayer.skip(for: -5, filePath: pathFinder.lastUsedUrl)
        }
    }
    
    @objc private func cutOffFrequencySliderValueChanged(_ sender: UISlider) {
        
        let value = round(sender.value * 10) / 10
        audioRecorder.cutOffFrequency = value
    }
    
    @objc private func audioPlaybackTimeIsOver(_ sender: Notification) {
        
        DispatchQueue.main.async { [unowned self] in
            
            playOrPauseButton.isSelected = false
            audioPlayer.stopPlay()
        }
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension VoiceMemoRecordViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
        if recordButton.isSelected {
            let alert = UIAlertController(title: nil,
                                          message: "녹음중인 파일이 저장되지 않습니다.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "확인", style: .default) { [unowned self] _ in
                
                dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(dismissAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
}

// MARK: - AudioBufferLiveDataDelegate

extension VoiceMemoRecordViewController: AudioBufferLiveDataDelegate {
    
    func communicationBufferData(bufferData: Float) {
        
        waveFormView.waveforms.append(bufferData)
        DispatchQueue.main.async { [unowned self] in
            
            waveFormView.setNeedsDisplay()
        }
    }
    
}
