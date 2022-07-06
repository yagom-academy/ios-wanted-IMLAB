//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/27.
//

import Foundation
import UIKit
import AVFoundation
import Combine

protocol RecordViewControllerDelegate: AnyObject {
    func recordViewControllerDidDisappear()
}

class RecordViewController:UIViewController {
    
    private var viewModel = RecordViewModel()
    weak var delegate: RecordViewControllerDelegate?
    private var cancellable = Set<AnyCancellable>()
    var timer: Timer?
    var timerNumber: Int = 0
    
    lazy var meterView: RecordMeterView = {
        let view = RecordMeterView(frame: .zero)
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    lazy var recordedTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 50), forImageIn: .normal)
        return button
    }()
    
    lazy var prevButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 30), forImageIn: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 30), forImageIn: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 30), forImageIn: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var controlStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [prevButton,playButton,nextButton])
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    lazy var volumeBar:UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.setValue(0.5, animated: false)
        return slider
    }()
    
    lazy var progressView:UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .secondarySystemGroupedBackground
        
        configure()
        
        bindProgress()
        bindIsPlaying()
        bindRecording()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.recordViewControllerDidDisappear()
    }
}

//MARK: - View Configure
private extension RecordViewController{
    func configure(){
        addSubViews()
        makeConstrains()
        configureButton()
    }
    
    func addSubViews(){
        [controlStackView,recordedTimeLabel,volumeBar,progressView,meterView,recordButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func makeConstrains(){
        NSLayoutConstraint.activate([
            meterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            meterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            meterView.topAnchor.constraint(equalTo: view.topAnchor,constant: 40),
            meterView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            recordedTimeLabel.centerXAnchor.constraint(equalTo: meterView.centerXAnchor),
            recordedTimeLabel.topAnchor.constraint(equalTo: meterView.bottomAnchor,constant: 10),
            recordedTimeLabel.heightAnchor.constraint(equalToConstant: 50),
            
            volumeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            volumeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30),
            volumeBar.topAnchor.constraint(equalTo: recordedTimeLabel.bottomAnchor,constant: 10),
            
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 30),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -30),
            progressView.topAnchor.constraint(equalTo: volumeBar.bottomAnchor,constant: 100),
            
            controlStackView.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            controlStackView.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            controlStackView.bottomAnchor.constraint(equalTo: recordButton.topAnchor,constant: -50),
            
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureButton(){
        self.recordButton.addTarget(self, action: #selector(didTapRecord(_:)), for: .touchUpInside)
        self.prevButton.addTarget(self, action: #selector(previusSec), for: .touchUpInside)
        self.nextButton.addTarget(self, action: #selector(nextSec), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(playPause(_:)), for: .touchUpInside)
        self.volumeBar.addTarget(self, action: #selector(touchSlider(_:)), for: .valueChanged)
    }
    
    @objc func didTapRecord(_ sender:UIButton){
        if viewModel.recorder.isRecording {
            viewModel.stopRec()
            sender.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
            
            self.playButton.isEnabled = true
            self.prevButton.isEnabled = true
            self.nextButton.isEnabled = true
        } else {
            viewModel.startRec()
            sender.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            startTimer()
        }
        
    }
    @objc func previusSec(){
        if viewModel.player.isPlaying {
            viewModel.seek(front: false)
        }
    }
    @objc func nextSec(){
        if viewModel.player.isPlaying {
            viewModel.seek(front: true)
        }
    }
    @objc func playPause(_ sender:UIButton){
        if viewModel.player.isPlaying {
            viewModel.stopAudio()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            viewModel.playAudio()
            sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
    }
    
    @objc func touchSlider(_ sender:UISlider!){
        viewModel.player.setVolume(sender.value, fadeDuration: 1)
    }
    
    func bindProgress() {
        viewModel.$progressValue
            .sink { [weak self] progress in
                self?.progressView.progress = progress
            }
            .store(in: &cancellable)
    }
    
    func bindIsPlaying() {
        viewModel.$isPlaying
            .sink { [weak self] isPlaying in
                self?.prevButton.isEnabled = isPlaying
                self?.nextButton.isEnabled = isPlaying
                self?.playButton.setImage(UIImage(systemName: isPlaying ? "stop.fill":"play.fill"), for: .normal)
            }
            .store(in: &cancellable)
    }
    
    func bindRecording() {
        viewModel.$isRecording
            .sink { [weak self] isRecording in
                print(isRecording)
                self?.meterView.disPlayLink?.isPaused = !isRecording
            }
            .store(in: &cancellable)
    }
    
    func startTimer() {
        if timer != nil && timer!.isValid {
            timer!.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallBack), userInfo: nil, repeats: false)
    }
    
    @objc private func timerCallBack() {
        self.recordedTimeLabel.text = "\(timerNumber) 초"
        timerNumber += 1
    }
}

extension RecordViewController: RecordDrawable {
    func clearAll() {
        self.meterView.values.removeAll()
        self.meterView.layer.sublayers = nil
    }
    
    func updateValue(_ value: CGFloat) {
        DispatchQueue.main.sync {
            self.meterView.values.append(value)
        }
    }
}
