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

    let buttons = PlayButtonView()
    var audio: Audio?
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setButtons()
    }
    private lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapRecordingButton), for: .touchDown)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("시작", for: .normal)
        button.setTitle("중지", for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapDoneButton), for: .touchDown)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    func setButtons(){
        buttons.translatesAutoresizingMaskIntoConstraints = false
        buttons.playButton.addTarget(self, action: #selector(tapPlayPauseButton), for: .touchUpInside)
        buttons.backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        buttons.forwordButton.addTarget(self, action: #selector(tapForwordButton), for: .touchUpInside)
    }
    func config(){
        view.addSubview(recordingButton)
        view.addSubview(buttons)
        NSLayoutConstraint.activate([
            recordingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            recordingButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            recordingButton.heightAnchor.constraint(equalToConstant: 50),
            recordingButton.widthAnchor.constraint(equalToConstant: 200),
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            buttons.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttons.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    @objc private func tapRecordingButton() {
        if recordingButton.isSelected{
            recordingButton.isSelected = false
            audioRecorder?.stop()
            audio = Audio(audioRecorder!.url)
        
            buttons.playButton.isEnabled = true
            buttons.backButton.isEnabled = true
            buttons.forwordButton.isEnabled = true
        }else{
            recordingButton.isSelected = true
            buttons.playButton.isEnabled = false
            buttons.backButton.isEnabled = false
            buttons.forwordButton.isEnabled = false
            self.record()
        }
    }
    @objc
    private func tapPlayPauseButton() {
//        guard !(audioRecorder?.isRecording)! else { return }
//        do {
//            if let audioRecorder = audioRecorder{
//                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
//                audioPlayer?.delegate = self
//                audioPlayer?.play()
//            }
//        } catch {
//            print("error: \(error.localizedDescription)")
//        }
        audio?.playOrPause()
    }
    @objc
    func tapBackButton() {
        guard audio != nil else { return }
        audio?.skip(forwards: false)
    }
    @objc
    func tapForwordButton() {
      guard audio != nil else { return }
      audio?.skip(forwards: true)
    }
    @objc
    func tapDoneButton() {

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



