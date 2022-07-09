//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/27.
//

import UIKit
import AVFoundation
import Combine

protocol RecordViewControllerDelegate: AnyObject {
    func uploadSuccess()
}

final class RecordViewController: UIViewController {
    
    private var viewModel = RecordViewModel()
    weak var delegate: RecordViewControllerDelegate?
    private var cancellable = Set<AnyCancellable>()
    var timer: Timer?
    var timerNumber: Int = 0
    let segmentItem: [String] = ["20kHz", "30kHz", "40kHz"]
    
    lazy var meterView: RecordMeterView = {
        let view = RecordMeterView(frame: .zero)
        return view
    }()
    
    lazy var recordedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = PlayerTime.zero.elapsedText
        label.textColor = .black
        return label
    }()
    
    lazy var cutOffFrequencySegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItem)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(changeSampleRate(_:)), for: .valueChanged)
        return segment
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.microphoneCustom, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 50), forImageIn: .normal)
        return button
    }()
    
    var controlStackView: PlaySeekStackView = PlaySeekStackView()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .secondarySystemGroupedBackground
        
        controlStackView.delegate = self
        
        configure()
        
        bindProgress()
        bindIsPlaying()
        bindRecording()
        bindTimer()
        bindError()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if viewModel.isRecording {
            viewModel.stopRec()
        }
        
        if viewModel.isPlaying {
            viewModel.stopAudio()
        }
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
        [controlStackView,recordedTimeLabel,cutOffFrequencySegmentControl,progressView,meterView,recordButton].forEach{
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
            
            cutOffFrequencySegmentControl.bottomAnchor.constraint(equalTo: progressView.topAnchor,constant: -30),
            cutOffFrequencySegmentControl.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            cutOffFrequencySegmentControl.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 30),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -30),
            progressView.bottomAnchor.constraint(equalTo: controlStackView.topAnchor,constant: -20),
            
            controlStackView.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            controlStackView.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            controlStackView.bottomAnchor.constraint(equalTo: recordButton.topAnchor,constant: -30),
            
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureButton(){
        self.recordButton.addTarget(self, action: #selector(didTapRecord(_:)), for: .touchUpInside)
        self.controlStackView.isReady(false)
    }
    
    @objc func didTapRecord(_ sender:UIButton){
        if !viewModel.isRecording {
            viewModel.startRec()
            sender.setImage(UIImage.recordingStop, for: .normal)
            
            controlStackView.isReady(false)
        } else {
            viewModel.stopRec()
            sender.setImage(UIImage.microPhone, for: .normal)
            
            controlStackView.isReady(true)
        }
    }
    
    @objc func changeSampleRate(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.changeSampleRate(20000.0)
        case 1:
            viewModel.changeSampleRate(30000.0)
        case 2:
            viewModel.changeSampleRate(40000.0)
        default:
            viewModel.changeSampleRate(44100.0)
        }
    }
    
    func showAlertController() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: Constants.Alert.error, message: Constants.Alert.empty, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Constants.Alert.ok, style: .default, handler: { _ in
                self.dismiss(animated: true)
            }))
            self.present(alertController, animated: true)
        }
    }
    
    func bindProgress() {
        viewModel.$progressValue
            .sink { [weak self] progress in
                self?.progressView.progress = progress
            }
            .store(in: &cancellable)
    }
    
    func bindRecording() {
        viewModel.$isRecording
            .sink { [weak self] isRecording in
                self?.recordButton.setImage(isRecording ? UIImage.recordingStop:UIImage.microPhone, for: .normal)
                self?.meterView.disPlayLink?.isPaused = !isRecording
                self?.cutOffFrequencySegmentControl.isEnabled = !isRecording
            }
            .store(in: &cancellable)
    }
    
    func bindIsPlaying() {
        viewModel.$isPlaying
            .sink { [weak self] isPlaying in
                self?.recordButton.isEnabled = !isPlaying
                self?.controlStackView.configurePlayPauseButtonState(isPlaying)
            }
            .store(in: &cancellable)
    }
    
    
    
    func bindTimer() {
        viewModel.$recordedTime
            .sink { playTime in
                self.recordedTimeLabel.text = playTime.elapsedText
            }
            .store(in: &cancellable)
    }
    
    func bindError() {
        viewModel.$isShowErrorAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isShowError in
                if isShowError {
                    self?.showAlertController()
                }
            }
            .store(in: &cancellable)
    }
}

extension RecordViewController: RecordDrawDelegate {
    func clearAll() {
        self.meterView.values.removeAll()
        self.meterView.layer.sublayers = nil
    }
    
    func updateValue(_ value: CGFloat) {
        DispatchQueue.main.sync {
            self.meterView.values.append(value)
        }
    }
    
    func uploadSuccess() {
        self.delegate?.uploadSuccess()
    }
}

extension RecordViewController: PlaySeekStackViewDelegate {
    func touchBackwardButton() {
        if viewModel.player.isPlaying {
            viewModel.seek(front: false)
        }
    }
    
    func touchForwardButton() {
        if viewModel.player.isPlaying {
            viewModel.seek(front: true)
        }
    }
    
    func touchPlayPauseButton() {
        if !viewModel.isPlaying {
            viewModel.playAudio()
        } else {
            viewModel.stopAudio()
        }
    }
}
