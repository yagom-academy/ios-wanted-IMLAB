//
//  RecordCheckViewController.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/06/28.
//

import UIKit
import AVFoundation

class RecordCheckViewController: UIViewController {
    
    var recordButton: UIButton = {
        var button = UIButton()
        //button.setImage(UIImage(named: "circle.fill"), for: .normal)
        //button.tintColor = .systemRed
        button.setTitle("record", for: .normal)
        button.backgroundColor = .systemRed
        return button
    }()
    
    var playButton: UIButton = {
        var button = UIButton()
        //button.setImage(UIImage(named: "play"), for: .normal)
        button.setTitle("play", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private var audioRecorder: AVAudioRecorder?
    private lazy var recordURL: URL = {
        var documentsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths.first!
        }()

        let fileName = UUID().uuidString + ".m4a"
        let url = documentsURL.appendingPathComponent(fileName)
        return url
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brown
        setLayout()
        
        recordButton.addTarget(self, action: #selector(control), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestMicrophoneAccess { [weak self] allowed in
            if allowed {
                // 녹음 권한 허용
                self?.configure()
            } else {
                // 녹음 권한 거부
            }
        }
    }
    
    func setLayout() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func recordButtonToggle() {
        DispatchQueue.main.async {
            self.playButton.isEnabled.toggle()
        }
    }
    
}

extension RecordCheckViewController {
    
    /// 마이크 접근 권한 요청
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
    
    /// 녹음 시작 & 정지 컨트롤
    @objc private func control() {
        
    }
    
    /// 녹음 시작
    private func record() {
        requestMicrophoneAccess { [weak self] allowed in
            if allowed {
                guard let self = self else { return }
                if let recorder = self.audioRecorder {
                    let audioSession = AVAudioSession.sharedInstance()
                    guard !recorder.isRecording else {
                        print("이미 녹음 중")
                        return
                    }

                    do {
                        try audioSession.setActive(true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }

                    recorder.record()
                    self.recordButtonToggle()
                }
            }
        }
    }

    /// 녹음 정지
    private func stop() {
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                self.audioRecorder?.stop()
                self.recordButtonToggle()
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(false)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
}

extension RecordCheckViewController: AVAudioRecorderDelegate {
    
    /// AVAudioRecorder 초기화
    private func configure() {
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        audioRecorder = try? AVAudioRecorder(url: recordURL, settings: recorderSettings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
    }
}
