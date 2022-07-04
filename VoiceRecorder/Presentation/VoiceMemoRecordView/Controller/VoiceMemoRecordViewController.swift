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
    
    // - MARK: UI init
    let waveView: UIView = {
        let view = UIView.init(frame: CGRect.init(origin: CGPoint.init(), size: CGSize.init(width: 100, height: 100)))
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let cutoffLabel: UILabel = {
        let label = UILabel()
        label.text = "cutoff freq"
        return label
    }()
    
    // 뭔지 모르겠네,, 컷오프를 정하는건지 재생시간을 표기한건지
    let cutOffFrequencySlider: UISlider = {
        let slider = UISlider()
        slider.value = 1
        
        return slider
    }()
    
    let playTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Play Time"
        return label
    }()
    
    let playOrPauseButton: UIButton = {
        let button = UIButton.init()
        
        button.setImage(UIImage.init(systemName: "play"), for: .normal)
        button.setImage(UIImage.init(systemName: "pause.fill"), for: .selected)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        return button
    }()
    
    let recordButton: UIButton = {
        let button = UIButton.init()
        
        button.tintColor = .systemRed
        button.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
        button.setImage(UIImage.init(systemName: "stop.fill"), for: .selected)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        return button
    }()
    
    let goForward5SecButton: UIButton = {
        let button = UIButton.init()
        
        button.setImage(UIImage.init(systemName: "goforward.5"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        return button
    }()
    
    let goBackward5SecButton: UIButton = {
        let button = UIButton.init()
        
        button.setImage(UIImage.init(systemName: "gobackward.5"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 35, weight: .regular, scale: .default), forImageIn: .normal)
        return button
    }()
    
    // MARK: - Properties
    let pathFinder = try! PathFinder()
    let audioManager = AudioManager()
    var timer: Timer?
    var playTime = 0
    
    // - MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        designateUIs()
        playRelatedButtonsHiddenAnimation(.record)
        configureTargetMethod()
    }
    
    private func configure() {
        self.view.backgroundColor = .white
    }
    
    // - MARK: UI Design
    
    private func designateUIs() {
        designateWaveView()
        designateCutOffLabel()
        designateSlider()
        designatePlayTimeLabel()
        designateButtons()
    }
    
    private func designateWaveView() {
        self.view.addSubview(waveView)
        waveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.1),
            waveView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            waveView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            waveView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func designateCutOffLabel() {
        self.view.addSubview(cutoffLabel)
        cutoffLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cutoffLabel.topAnchor.constraint(equalTo: waveView.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            cutoffLabel.leadingAnchor.constraint(equalTo: waveView.safeAreaLayoutGuide.leadingAnchor),
            cutoffLabel.trailingAnchor.constraint(equalTo: waveView.safeAreaLayoutGuide.trailingAnchor),
            
            cutoffLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func designateSlider() {
        self.view.addSubview(cutOffFrequencySlider)
        cutOffFrequencySlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cutOffFrequencySlider.topAnchor.constraint(equalTo: cutoffLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            cutOffFrequencySlider.leadingAnchor.constraint(equalTo: cutoffLabel.safeAreaLayoutGuide.leadingAnchor),
            cutOffFrequencySlider.trailingAnchor.constraint(equalTo: cutoffLabel.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func designatePlayTimeLabel() {
        self.view.addSubview(playTimeLabel)
        playTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playTimeLabel.topAnchor.constraint(equalTo: cutOffFrequencySlider.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            
            playTimeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func designateButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.addArrangedSubview(recordButton)
        stackView.addArrangedSubview(goBackward5SecButton)
        stackView.addArrangedSubview(playOrPauseButton)
        stackView.addArrangedSubview(goForward5SecButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo:playTimeLabel.safeAreaLayoutGuide.bottomAnchor, constant: 35),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Method
    private func configureTargetMethod() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
        playOrPauseButton.addTarget(self, action: #selector(playOrPauseButtonTapped(_:)), for: .touchUpInside)
        goForward5SecButton.addTarget(self, action: #selector(move5SecondsButtonTapped(_:)), for: .touchUpInside)
        goBackward5SecButton.addTarget(self, action: #selector(move5SecondsButtonTapped(_:)), for: .touchUpInside)
        cutOffFrequencySlider.addTarget(self, action: #selector(cutOffFrequencySliderValueChanged(_:)), for: .valueChanged )
    }
    
    /// 녹음완료후 음성파일의 시간
    private func showVoiceMemoDuration() -> String {
        return audioManager.getPlayTime(filePath: pathFinder.lastUsedUrl)
    }
    
    /// 플레이관련 버튼들의 hidden animation
    private func playRelatedButtonsHiddenAnimation(_ mode: RecordViewJobMode) {
        let playRelatedButtons = [playOrPauseButton, goBackward5SecButton, goForward5SecButton]
        UIView.animate(withDuration: 0.05) {
            if mode == .record {
                playRelatedButtons.forEach { $0.isHidden = true }
            } else {
                playRelatedButtons.forEach { $0.isHidden = false }
            }
        }
    }
    
    private func removeTimer() {
        self.playOrPauseButton.isSelected = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - TargetMethod
extension VoiceMemoRecordViewController {
    @objc private func recordButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            removeTimer()
            playTime = 0
            playTimeLabel.text = ""
            playRelatedButtonsHiddenAnimation(.record)
            audioManager.startRecord(filePath: pathFinder.getPathWithTime())
        } else {
            playRelatedButtonsHiddenAnimation(.play)
            audioManager.stopRecord()
            playTimeLabel.text = showVoiceMemoDuration()
        }
    }
    
    @objc private func playOrPauseButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            audioManager.startPlay(fileURL: pathFinder.lastUsedUrl)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(compareVoiceMemoTime), userInfo: nil, repeats: true)
        } else {
            removeTimer()
            audioManager.pausePlay()
        }
    }
    
    @objc private func move5SecondsButtonTapped(_ sender: UIButton) {
        if sender === goForward5SecButton {
            audioManager.skip(for: 5, filePath: pathFinder.lastUsedUrl)
        } else {
            audioManager.skip(for: -5, filePath: pathFinder.lastUsedUrl)
        }
    }
    
    @objc private func cutOffFrequencySliderValueChanged(_ sender: UISlider) {
        let value = round(sender.value * 10) / 10
        audioManager.cutOffFrequency = value
    }
    
    @objc private func compareVoiceMemoTime() {
        playTime += 1
        if String(playTime) >= audioManager.getPlayTime(filePath: pathFinder.lastUsedUrl) {
            playTime = 0
            playOrPauseButton.isSelected = false
            audioManager.stopPlay()
            removeTimer()
        }
    }
}

