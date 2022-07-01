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

class RecordViewController:UIViewController{
    let firebaseManger = FirebaseStorageManager.shared
    let step:Float = 10
    var isPermissionGrant:Bool = false
    private var audioEngine: Engine?
    
    lazy var recordButton:UIButton = {
        let button = UIButton().playControlButton("circle.fill", state: .normal)
        return button
    }()
    
    lazy var prevButton:UIButton = {
        let button = UIButton().playControlButton("gobackward.5", state: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var nextButton:UIButton = {
        let button = UIButton().playControlButton("goforward.5", state: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var playButton:UIButton = {
        let button = UIButton().playControlButton("play.fill", state: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var controlStackView:UIStackView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureEngineAndSetup()
        checkPermission()
        configure()
        
        audioEngine?.progressValue.observe(on: self){ [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.progress = progress
            }
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
        
        [controlStackView,volumeBar,progressView].forEach{
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
            progressView.bottomAnchor.constraint(equalTo: volumeBar.topAnchor,constant: -30)
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
        if isPermissionGrant{
            guard let audioEngine = audioEngine else {
                return
            }

            audioEngine.checkEngineRunning()
            self.toggleRecording()
            
            if audioEngine.isRecording{
                sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                playButton.isEnabled = false
                prevButton.isEnabled = false
                nextButton.isEnabled = false
            }else{
                sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                playButton.isEnabled = true
                prevButton.isEnabled = true
                nextButton.isEnabled = true
            }
        }else{
            sender.isEnabled = false
        }
        
        //TODO: - Permission denied
        
    }
    @objc func previusSec(){
        print("Tapped prev")
        guard let audioEngine = audioEngine else {
            return
        }

        audioEngine.checkEngineRunning()
        audioEngine.skip(forwards: false)
        self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    @objc func nextSec(){
        print("Tapped next")
        guard let audioEngine = audioEngine else {
            return
        }
        audioEngine.checkEngineRunning()
        audioEngine.skip(forwards: true)
    }
    @objc func playPause(_ sender:UIButton){
        print("tapped play Button")
        guard let audioEngine = audioEngine else {
            return
        }
        audioEngine.checkEngineRunning()
        audioEngine.togglePlaying {
            DispatchQueue.main.async {
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
        
        if audioEngine.isPlaying{
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }else{
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func touchSlider(_ sender:UISlider!){
        guard let audioEngine = audioEngine else {
            return
        }
        audioEngine.player.volume = sender.value
    }
}

extension RecordViewController:Recordable{

    func configureEngineAndSetup(){
        configureEngine()
        setup()
    }
    func configureEngine(){
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            self.audioEngine = try Engine(fileURL: URL(fileURLWithPath: "input.caf",
                                                       isDirectory: false,
                                                       relativeTo: URL(fileURLWithPath: NSTemporaryDirectory())))
        } catch {
            print("Could not configure Engine")
        }
    }
    
    func setup() {
        guard let audioEngine = audioEngine else {
            return
        }
        
        audioEngine.engine.attach(audioEngine.player)
        let input = audioEngine.engine.inputNode
        
        do{
            try input.setVoiceProcessingEnabled(true)
        } catch {
            print("Could not enable voice processing \(error)")
            return
        }
        
        let output = audioEngine.engine.outputNode
        let mainMixer = audioEngine.engine.mainMixerNode
        
        audioEngine.engine.connect(audioEngine.player, to: mainMixer, format: audioEngine.voiceIOFormat)
        audioEngine.engine.connect(mainMixer, to: output, format: audioEngine.voiceIOFormat)
        
        input.installTap(onBus: 0, bufferSize: 256, format: audioEngine.voiceIOFormat) { buffer, when in
            if audioEngine.isRecording{
                print(buffer)
                do{
                    try audioEngine.recordFile?.write(from: buffer)
                } catch {
                    print("Could not write buffer \(error)")
                }
            }
        }
        
        mainMixer.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, when in
            
        }
        
        audioEngine.engine.prepare()
        audioEngine.engineStart()
    }
    
    func toggleRecording() {
        guard let audioEngine = audioEngine else {
            return
        }
        if audioEngine.isRecording{
            audioEngine.isRecording = false
            audioEngine.recordFile = nil
        } else {
            audioEngine.player.stop()
            
            do{
                audioEngine.recordFile = try AVAudioFile(forWriting: audioEngine.fileURL, settings: audioEngine.voiceIOFormat.settings)
                
                audioEngine.isRecording = true
            } catch {
                print("Could not create file for recording \(error)")
            }
        }
    }
}

extension RecordViewController{
    private func checkPermission(){
        switch AVAudioSession.sharedInstance().recordPermission{
        case .granted:
            isPermissionGrant = true
        case .denied:
            isPermissionGrant = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                self.isPermissionGrant = allowed
            }
        @unknown default:
            fatalError("Error in permission")
        }
    }
}
