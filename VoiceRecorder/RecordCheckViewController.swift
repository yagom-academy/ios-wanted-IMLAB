//
//  RecordCheckViewController.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/06/28.
//

import UIKit
import AVFoundation

class RecordCheckViewController: UIViewController {
    
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

extension RecordCheckViewController: AVAudioRecorderDelegate {
    
}
