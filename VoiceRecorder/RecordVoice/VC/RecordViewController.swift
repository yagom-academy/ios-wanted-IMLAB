//
//  RecordViewController.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/04.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    private var soundManager = SoundManager()
    private var audioFileManager = AudioFileManager()
    private var firebaseStorageManager = FirebaseStorageManager()
    
    private let date = DateUtil().currentDate
    private lazy var urlString = "\(self.date).caf"
    
    //private let recordAuthorizationStatus
    private var isStartRecording: Bool = false
    
    private var visualizer: AudioVisualizeView = {
        var visualizer = AudioVisualizeView()
        visualizer.translatesAutoresizingMaskIntoConstraints = false
        return visualizer
    }()
    
    private lazy var playControlView: PlayControlView = {
        var view = PlayControlView()
        view.delegate = self
        return view
    }()
    
    private var frequencyControlView: FrequencyControlView = {
        var view = FrequencyControlView()
        return view
    }()
    
    private var recordButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        let largeRecordImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
        button.setImage(largeRecordImage, for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setAudio()
        soundManager.visualDelegate = self
        frequencyControlView.delegate = self
        
        recordButton.addTarget(self, action: #selector(controlRecord), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requestMicrophoneAccess { [self] allowed in
            if !allowed {
                requestMicrophoneAccessDeniedHandler()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .dismissVC, object: nil)
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        
        playControlView.translatesAutoresizingMaskIntoConstraints = false
        frequencyControlView.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualizer)
        view.addSubview(playControlView)
        view.addSubview(frequencyControlView)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            
            visualizer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            visualizer.centerYAnchor.constraint(equalTo: view.centerYAnchor).constraintWithMultiplier(0.5),
            visualizer.widthAnchor.constraint(equalTo: view.widthAnchor),
            visualizer.heightAnchor.constraint(equalToConstant: 200),
            
            playControlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playControlView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playControlView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            playControlView.heightAnchor.constraint(equalToConstant: 100),
            
            frequencyControlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frequencyControlView.topAnchor.constraint(equalTo: playControlView.bottomAnchor, constant: 40),
            frequencyControlView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            frequencyControlView.heightAnchor.constraint(equalToConstant: 80),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setAudio() {
        requestMicrophoneAccess { [self] allowed in
            guard allowed == true else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
                return
            }
            
            let localUrl = audioFileManager.getAudioFilePath(fileName: urlString)
            soundManager.initializeSoundManager(url: localUrl, type: .record)
        }
    }
    
    private func requestMicrophoneAccessDeniedHandler() {
        let alert = UIAlertController(title: "녹음 권한 거부", message: "녹음 권한을 설정해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            DispatchQueue.main.async {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL,
                                              options: [:],
                                              completionHandler: nil)
                }
            }
        }
        let cancleAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancleAction)
        self.present(alert, animated: true)
    }
    
    private func recordButtonToggle() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        let largeRecordImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
        let largePauseImage = UIImage(systemName: "square.circle", withConfiguration: largeConfig)
        
        let image = self.isStartRecording ? largePauseImage : largeRecordImage
        self.recordButton.setImage(image, for: .normal)
    }
    
    private func passData(localUrl : URL) {
        let data = try! Data(contentsOf: localUrl)
        let totalTime = soundManager.totalPlayTime(date: date)
        let duration = soundManager.convertTimeToString(totalTime)
        let audioMetaData = AudioMetaData(title: date, duration: duration, url: urlString)
        
        firebaseStorageManager.uploadAudio(audioData: data, audioMetaData: audioMetaData)
    }
    
    // 녹음 시작 & 정지 컨트롤
    @objc private func controlRecord() {
        isStartRecording = !isStartRecording
        recordButtonToggle()
        
        if isStartRecording { // 녹음 시작일 때
            soundManager.startRecord()
        } else { // 녹음 끝일 때
            soundManager.stopRecord()
            
            let localUrl = audioFileManager.getAudioFilePath(fileName: urlString)
            print(localUrl)
            passData(localUrl: localUrl)
            soundManager.initializeSoundManager(url: localUrl, type: .playBack)
        }
    }
}

extension RecordViewController {
    
    // 마이크 접근 권한 요청
    private func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        do {
            let recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
            switch recordingSession.recordPermission {
            case .undetermined: // 아직 녹음 권한 요청이 되지 않음, 사용자에게 권한 요청
                recordingSession.requestRecordPermission({ allowed in // bool 값
                    completion(allowed)
                })
            case .denied: // 사용자가 녹음 권한 거부, 사용자가 직접 설정 화면에서 권한 허용을 하게끔 유도
                print("[Failure] Record Permission is Denied.")
                completion(false)
            case .granted: // 사용자가 녹음 권한 허용
                print("[Success] Record Permission is Granted.")
                completion(true)
            @unknown default:
                fatalError("[ERROR] Record Permission is Unknown Default.")
            }
        }
    }
}

extension RecordViewController: Visualizerable {
    
    func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        visualizer.processAudioData(buffer: buffer)
    }
}

extension RecordViewController: SoundButtonActionDelegate {
    
    func playButtonTouchUpinside(sender: UIButton) {
        guard soundManager.isEnginePrepared else { return }
        self.soundManager.playNpause()
    }
    
    func backwardButtonTouchUpinside(sender: UIButton) {
        print("backwardButton Clicked")
        soundManager.skip(isForwards: false)
    }
    
    func forwardTouchUpinside(sender: UIButton) {
        print("forwardButton Clicked")
        soundManager.skip(isForwards: true)
    }
}

extension RecordViewController : SliderEvnetDelegate {
    
    func sliderEventValueChanged(sender: UISlider) {
        soundManager.frequency = sender.value
    }
}
