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
    
    private var isStartRecording: Bool = false
    
    private var visualizer: AudioVisualizeView = {
        var visualizer = AudioVisualizeView(playType: .record)
        visualizer.translatesAutoresizingMaskIntoConstraints = false
        return visualizer
    }()
    
    private lazy var playControlView: PlayControlView = {
        var view = PlayControlView()
        view.isPlayButtonActivate = false
        view.delegate = self
        return view
    }()
    
    private var sliderFrequency: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 20000
        slider.maximumValue = 40000
        slider.value = 30000
        return slider
    }()
    
    private var recordButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        let largeRecordImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
        button.setImage(largeRecordImage, for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private var processSlider: UISlider = {
        var slider = UISlider()
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setAudio()
        soundManager.recordVisualizerDelegate = self
        soundManager.playBackVisualizerDelegate = self
        soundManager.delegate = self
        recordButton.addTarget(self, action: #selector(controlRecord), for: .touchUpInside)
        sliderFrequency.addTarget(self, action: #selector(onChangeValueSlider(sender:)), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .dismissVC, object: nil)
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        
        playControlView.translatesAutoresizingMaskIntoConstraints = false
        sliderFrequency.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualizer)
        view.addSubview(playControlView)
        view.addSubview(sliderFrequency)
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
            
            sliderFrequency.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sliderFrequency.topAnchor.constraint(equalTo: playControlView.bottomAnchor, constant: 40),
            sliderFrequency.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            sliderFrequency.heightAnchor.constraint(equalToConstant: 30),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setAudio() {
        requestMicrophoneAccess { [self] allowed in
            if allowed {
                let localUrl = audioFileManager.getAudioFilePath(fileName: urlString)
                soundManager.initializeSoundManager(url: localUrl, type: .record)
            } else {
                print("녹음 권한이 거부되었습니다.")
            }
        }
    }
    
    private func recordButtonToggle() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        let largeRecordImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
        let largePauseImage = UIImage(systemName: "square.circle", withConfiguration: largeConfig)
        
        let image = self.isStartRecording ? largePauseImage : largeRecordImage
        self.recordButton.setImage(image, for: .normal)
    }
    
    private func passData(localUrl : URL) {
        do {
            let data = try Data(contentsOf: localUrl)
            let audioFile = try soundManager.getAudioFile(filePath: localUrl)
            let totalTime = soundManager.totalPlayTime(audioFile: audioFile)
            let duration = convertTimeToString(totalTime)
            let wavefrom = visualizer.getWaveformData()
            let audioMetaData = AudioMetaData(title: date, duration: duration, url: urlString, waveforms: wavefrom)
            
            firebaseStorageManager.uploadAudio(audioData: data, audioMetaData: audioMetaData)
        } catch {
            
        }
    }
    
    func convertTimeToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        
        return strTime
    }
    
    
    // 녹음 시작 & 정지 컨트롤
    @objc private func controlRecord() {
        isStartRecording = !isStartRecording
        playControlView.isPlayButtonActivate = !isStartRecording
        visualizer.isTouchable = !isStartRecording
        recordButtonToggle()
        
        if isStartRecording { // 녹음 시작일 때
            soundManager.startRecord()
        } else { // 녹음 끝일 때
            soundManager.stopRecord()
            playControlView.isPlayButtonActivate = !isStartRecording
            visualizer.isTouchable = !isStartRecording
            let localUrl = audioFileManager.getAudioFilePath(fileName: urlString)
            passData(localUrl: localUrl)
            soundManager.initializeSoundManager(url: localUrl, type: .playBack)
        }
    }
    
    @objc func onChangeValueSlider(sender: UISlider) {
        soundManager.frequency = sender.value
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

extension RecordViewController: SoundButtonActionDelegate {
    
    func playButtonTouchUpinside(sender: UIButton) {
        guard soundManager.isEnginePrepared else { return }
        visualizer.moveToStartingPoint()
        soundManager.playNpause()
    }
    
    func backwardButtonTouchUpinside(sender: UIButton) {
        soundManager.skip(isForwards: false)
    }
    
    func forwardTouchUpinside(sender: UIButton) {
        soundManager.skip(isForwards: true)
    }
}

extension RecordViewController: RecordingVisualizerable, PlaybackVisualizerable {
    
    func operatingwaveProgression(progress: Float, audioLength: Float) {
        DispatchQueue.main.async { [self] in
            visualizer.operateVisualizerMove(value: progress, audioLenth: audioLength, centerViewMargin: visualizer.frame.minX)
        }
    }
    
    func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        visualizer.processAudioData(buffer: buffer)
    }
    
}

extension RecordViewController: SoundManagerStatusReceivable {
    
    func audioPlayerCurrentStatus(isPlaying: Bool) {
        soundManager.removeTap()
        DispatchQueue.main.async {
            self.playControlView.isSelected = isPlaying
            self.visualizer.moveToStartingPoint()
        }
    }
    
    func audioFileInitializeErrorHandler(error: Error) {
        let alert = UIAlertController(title: "파일 초기화 실패!", message: "오류코드: \(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func audioEngineInitializeErrorHandler(error: Error) {
        let alert = UIAlertController(title: "엔진 초기화 실패!", message: "오류코드: \(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}
