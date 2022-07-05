//
//  ViewController.swift
//  VoiceRecorder
//
//  Created by dong eun shin on 2022/06/29.
//

import UIKit

import AVFoundation
import FirebaseStorage

class CreateAudioViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    private lazy var playButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordingButton, rewindButton, playPauseButton, forwardButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapRecordingButton), for: .touchDown)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("시작", for: .normal)
        button.setTitle("중지", for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var rewindButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(tapPlayPauseButton), for: .touchDown)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func config(){
        view.addSubview(playButtonStackView)
        playButtonStackView.addSubview(recordingButton)
        playButtonStackView.addSubview(rewindButton)
        playButtonStackView.addSubview(playPauseButton)
        playButtonStackView.addSubview(forwardButton)
        
        NSLayoutConstraint.activate([
            playButtonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.3),
            playButtonStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButtonStackView.heightAnchor.constraint(equalToConstant: 50),
            playButtonStackView.widthAnchor.constraint(equalToConstant: 200),
            
            recordingButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            rewindButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
            forwardButton.centerYAnchor.constraint(equalTo: playButtonStackView.centerYAnchor),
        ])
    }
    
    @objc private func tapRecordingButton() {
        if recordingButton.isSelected{
            recordingButton.isSelected = false
            audioRecorder?.stop()
            do {
                if let audioRecorder = audioRecorder{
                    let data = try Data(contentsOf: audioRecorder.url)
                    let customData = CustomMetadata(length: "1")
                    let test = StorageMetadata()
                    test.customMetadata = customData.toDict()
                    test.contentType = CustomMetadata.fileType
                    let audioInfo = AudioInfo(id: UUID().uuidString, data: data, metadata: test)
                    FirebaseService.uploadAudio(audio: audioInfo) { result in
                        switch result {
                        case .success(let metadata):
                            print(metadata)
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
//                    FirebaseService.uploadAudio(fileName: "shinTmp.mp3", data: data) { err in
//                        print("firebase err: \(String(describing: err?.localizedDescription))")
//                    }
                    // Data로 변환됐는지 확인하기 위한 부분
//                    do {
//                        try audioPlayer = AVAudioPlayer(data: data)
//                        audioPlayer?.delegate = self
//                        audioPlayer?.play()
//                    } catch {
//                        print("error: \(error.localizedDescription)")
//                    }
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
            playPauseButton.isEnabled = true
            rewindButton.isEnabled = true
            forwardButton.isEnabled = true
        }else{
            recordingButton.isSelected = true
            playPauseButton.isEnabled = false
            rewindButton.isEnabled = false
            forwardButton.isEnabled = false
            self.record()
        }
    }
    @objc private func tapPlayPauseButton() {
        guard !(audioRecorder?.isRecording)! else { return }
        do {
            if let audioRecorder = audioRecorder{
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    func record() {
      let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("fileName.m4a")
      let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
      ]
      
      do {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
      } catch {
        print("error: \(error.localizedDescription)")
      }
      
      do {
        self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
          self.audioRecorder?.delegate = self
          self.audioRecorder?.record()
      } catch {
        print("error: \(error.localizedDescription)")
          self.audioRecorder?.stop()
      }
    }
}
