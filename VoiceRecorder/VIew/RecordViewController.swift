//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/27.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import Combine

protocol RecordViewControllerDelegate: AnyObject {
    func recordViewControllerDidDisappear()
}

class RecordViewController:UIViewController{

    
    private var viewModel:RecordViewModel!
    private var cancellable = Set<AnyCancellable>()
    
    weak var delegate: RecordViewControllerDelegate?
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        return button
    }()
    
    lazy var prevButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var controlStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordButton,prevButton,playButton,nextButton])
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    lazy var volumeBar:UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.setValue(50, animated: false)
        return slider
    }()
    
    lazy var progressView:UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    lazy var meterView: RecordMeterView = {
        let view = RecordMeterView(frame: .zero)
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemGroupedBackground
        
        setupViewModel()
        configure()
        
        bindProgress()
        bindPlayButton()
        bindRecordButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        viewModel.player.stop()
        viewModel.engine.stop()
        do{
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Could not set active false")
        }
        
        delegate?.recordViewControllerDidDisappear()
        super.viewDidDisappear(animated)
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
        
        [controlStackView,volumeBar,progressView,meterView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func makeConstrains(){
        NSLayoutConstraint.activate([
            controlStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            controlStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -50),
            
            volumeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            volumeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30),
            volumeBar.bottomAnchor.constraint(equalTo: controlStackView.topAnchor,constant: -50),
            
            progressView.leadingAnchor.constraint(equalTo: volumeBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: volumeBar.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: volumeBar.topAnchor,constant: -30),
            
            meterView.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            meterView.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            meterView.bottomAnchor.constraint(equalTo: progressView.topAnchor,constant: -30),
            meterView.heightAnchor.constraint(equalToConstant: 80),
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
        
        viewModel.checkEngineRunning()
        
        if viewModel.isRecording {
            viewModel.stopRecording()
        } else {
            viewModel.startRecord()
            viewModel.progressValue = 0
            viewModel.isPlaying = false
        }
        
    }
    @objc func previusSec(){
        viewModel.checkEngineRunning()
        viewModel.skip(forwards: false)
    }
    @objc func nextSec(){
        viewModel.checkEngineRunning()
        viewModel.skip(forwards: true)
    }
    @objc func playPause(_ sender:UIButton){
        viewModel.checkEngineRunning()
        
        if viewModel.player.isPlaying{
            viewModel.stopPlaying()
        } else {
            viewModel.startPlaying()
        }
    }
    
    @objc func touchSlider(_ sender:UISlider!){
        viewModel.engine.inputNode.volume = sender.value
        viewModel.engine.mainMixerNode.outputVolume = sender.value
    }
    
    func setupViewModel(){
        do{
            self.viewModel = try RecordViewModel()
            self.viewModel.delegate = self
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Could not init viewmodel")
        }
    }
}

extension RecordViewController {
    private func bindPlayButton() {
        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { isPlaying in
                if isPlaying{
                    self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    [self.prevButton,self.nextButton].forEach { button in
                        button.isEnabled = true
                    }
                } else {
                    self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    
                    if self.viewModel.audioLengthSeconds == 0{
                        self.playButton.isEnabled = false
                    }
                    
                    [self.prevButton,self.nextButton].forEach { button in
                        button.isEnabled = false
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    private func bindRecordButton(){
        viewModel.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { isRecording in
                if isRecording {
                    self.recordButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                    
                    [self.prevButton,self.playButton,self.nextButton].forEach { button in
                        button.isEnabled = false
                    }
                    self.meterView.disPlayLink?.isPaused = false
                } else {
                    self.recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                    
                    [self.prevButton,self.playButton,self.nextButton].forEach { button in
                        button.isEnabled = true
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    private func bindProgress(){
        viewModel.$progressValue
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.progressView.progress = value
            }
            .store(in: &cancellable)
    }
}

extension RecordViewController: RecordDrawable {
    func updateValue(_ value:CGFloat) {
        self.meterView.value = value
    }
}

extension RecordViewController: UIScrollViewDelegate {}
