//
//  RecordVoiceViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

protocol RecordVoiceDelegate : AnyObject{
    func updateList()
}

enum AudioStatus {
    case beforeRecording, afterRecording, beforePlaying, afterPlaying, forward, backward
}

import UIKit
import AVFoundation

class RecordVoiceViewController: UIViewController{
    
    weak var delegate : RecordVoiceDelegate?
    var recordVoiceManager : RecordVoiceManager!
    var drawWaveFormManager : DrawWaveFormManager!
    var playVoiceManager : PlayVoiceManager!
    var audioSessionManager = AudioSessionManager()
    var isHour = false
    
    let waveFormCanvasView : UIView = {
        let waveFormCanvasView = UIView()
        waveFormCanvasView.translatesAutoresizingMaskIntoConstraints = false
        waveFormCanvasView.frame.size.width = CGFloat(FP_INFINITE)
        return waveFormCanvasView
    }()
    
    let waveFormBackgroundView : UIView = {
        let waveFormBackgroundView = UIView()
        waveFormBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        waveFormBackgroundView.backgroundColor = .systemGray6
        return waveFormBackgroundView
    }()
    
    var waveFormView : WaveFormView = {
        let waveFormView = WaveFormView()
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
        return waveFormView
    }()
    
    let frequencyLabel : UILabel = {
        let frequencyLabel = UILabel()
        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        return frequencyLabel
    }()
    
    lazy var frequencySlider : UISlider = {
        let frequencySlider = UISlider()
        frequencySlider.translatesAutoresizingMaskIntoConstraints = false
        frequencySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        frequencySlider.minimumValue = CNS.sampleRate.min
        frequencySlider.maximumValue = CNS.sampleRate.max
        return frequencySlider
    }()
    
    let progressTimeLabel : TimeLabel = {
        let progressTimeLabel = TimeLabel()
        progressTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return progressTimeLabel
    }()
    
    let buttonStackView : UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 30
        return buttonStackView
    }()
    
    lazy var record_start_stop_button : UIButton = {
        let record_start_stop_button = UIButton()
        record_start_stop_button.translatesAutoresizingMaskIntoConstraints = false
        record_start_stop_button.addTarget(self, action: #selector(tab_record_start_stop_Button), for: .touchUpInside)
        record_start_stop_button.setPreferredSymbolConfiguration(.init(pointSize: CNS.size.recordButton), forImageIn: .normal)
        return record_start_stop_button
    }()
    
    var recordFile_ButtonStackView : UIStackView = {
        let recordFile_ButtonStackView = UIStackView()
        recordFile_ButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        recordFile_ButtonStackView.axis = .horizontal
        recordFile_ButtonStackView.spacing = 20
        return recordFile_ButtonStackView
    }()
    
    lazy var recordFile_play_PauseButton: UIButton = {
        let recordFile_play_PauseButton = UIButton()
        recordFile_play_PauseButton.translatesAutoresizingMaskIntoConstraints = false
        recordFile_play_PauseButton.setPreferredSymbolConfiguration(.init(pointSize: CNS.size.playButton), forImageIn: .normal)
        recordFile_play_PauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        recordFile_play_PauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return recordFile_play_PauseButton
    }()
    
    lazy var forwardFive: UIButton = {
        let forwardFive = UIButton()
        forwardFive.translatesAutoresizingMaskIntoConstraints = false
        forwardFive.setPreferredSymbolConfiguration(.init(pointSize: CNS.size.playButton), forImageIn: .normal)
        forwardFive.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        forwardFive.addTarget(self, action: #selector(tabForward), for: .touchUpInside)
        return forwardFive
    }()
    
    lazy var backwardFive: UIButton = {
        let backwardFive = UIButton()
        backwardFive.translatesAutoresizingMaskIntoConstraints = false
        backwardFive.setPreferredSymbolConfiguration(.init(pointSize: CNS.size.playButton), forImageIn: .normal)
        backwardFive.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        backwardFive.addTarget(self, action: #selector(tabBackward), for: .touchUpInside)
        return backwardFive
    }()
    
    @objc func tab_record_start_stop_Button(){
        if recordVoiceManager.isRecording(){
            var time = progressTimeLabel.text!
            if !isHour{
                time = time[0..<5]
            }
            drawWaveFormManager.stopDrawing(in: waveFormCanvasView)
            recordVoiceManager.stopRecording() {
                self.playVoiceManager.setNewScheduleFile()
                FirebaseStorageManager().uploadRecord(time: time) {
                    self.delegate?.updateList()
                }
            }
            record_start_stop_button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            record_start_stop_button.tintColor = .red
            updateUI(when: .afterRecording)
            print("recording stop")
        }else{
            recordVoiceManager.startRecording()
            drawWaveFormManager.startDrawing(of: recordVoiceManager.recorder!, in: waveFormCanvasView)
            record_start_stop_button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            record_start_stop_button.tintColor = .black
            updateUI(when: .beforeRecording)
            print("recording start")
        }
    }
    
    @objc func sliderValueChanged(){
        audioSessionManager.setSampleRate(Double(frequencySlider.value))
        frequencyLabel.text = "cutoff frequency: \(Int(audioSessionManager.getSampleRate()))Hz"
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        drawWaveFormManager.delegate = self
        recordVoiceManager.delegate = self
        playVoiceManager.delegate = self
        audioSessionManager.setSampleRate(Double(CNS.sampleRate.max))
        
        setView()
        autoLayout()
        setUI()
    }
    
    func setView(){
        self.view.addSubview(waveFormBackgroundView)
        self.view.addSubview(waveFormCanvasView)
        self.view.addSubview(waveFormView)
        self.view.addSubview(frequencyLabel)
        self.view.addSubview(frequencySlider)
        self.view.addSubview(progressTimeLabel)
        self.view.addSubview(buttonStackView)
        self.view.addSubview(recordFile_ButtonStackView)
        for item in [ backwardFive, recordFile_play_PauseButton, forwardFive ]{
            recordFile_ButtonStackView.addArrangedSubview(item)
        }
        
        self.buttonStackView.addArrangedSubview(record_start_stop_button)
        self.buttonStackView.addArrangedSubview(recordFile_ButtonStackView)
        
    }
    
    func autoLayout(){
        NSLayoutConstraint.activate([
            
            waveFormBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveFormBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            waveFormBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormBackgroundView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            waveFormView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveFormView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            waveFormView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            progressTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressTimeLabel.bottomAnchor.constraint(equalTo: waveFormView.topAnchor, constant: -CNS.autoLayout.minConstant),
            
            waveFormCanvasView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormCanvasView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            waveFormCanvasView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            frequencyLabel.topAnchor.constraint(equalTo: waveFormView.bottomAnchor, constant: CNS.autoLayout.standardConstant),
            frequencyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CNS.autoLayout.standardWidthMP),
            frequencyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            frequencySlider.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor),
            frequencySlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CNS.autoLayout.standardWidthMP),
            frequencySlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: frequencySlider.bottomAnchor, constant: CNS.autoLayout.standardConstant),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func setUI(){
        frequencyLabel.text = "cutoff frequency: \(Int(audioSessionManager.getSampleRate()))Hz"
        frequencySlider.value = CNS.sampleRate.max
        record_start_stop_button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        record_start_stop_button.tintColor = .red
        recordFile_ButtonStackView.isHidden = true
        waveFormView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool){
        if recordVoiceManager.isRecording(){
            recordVoiceManager.stopRecording() {
                self.drawWaveFormManager.stopDrawing(in: self.waveFormCanvasView)
                FirebaseStorageManager().uploadRecord(time: self.progressTimeLabel.text!) {
                    self.delegate?.updateList()
                }
            }
        }
        playVoiceManager.closeAudio()
    }
    
    func updateUI(when status : AudioStatus){
        switch status {
        case .beforeRecording:
            self.record_start_stop_button.isEnabled = false
            UIView.animate(withDuration: 0.2) {
                self.recordFile_ButtonStackView.alpha = 0.0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.recordFile_ButtonStackView.isHidden = true
                }
                self.record_start_stop_button.isEnabled = true
            }
            frequencySlider.isEnabled = false
            frequencySlider.tintColor = .darkGray
            waveFormCanvasView.isHidden = false
            waveFormView.isHidden = true
        case .afterRecording:
            UIView.animate(withDuration: 0.3) {
                self.recordFile_ButtonStackView.isHidden = false
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.recordFile_ButtonStackView.alpha = 1.0
                }
            }
            frequencySlider.isEnabled = true
            frequencySlider.tintColor = .systemBlue
            waveFormView.imageView.image = drawWaveFormManager.getWaveFormImage()
            progressTimeLabel.setText(playVoiceManager.getAudioFileLengthSecond())
            recordFile_play_PauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        case .beforePlaying:
            waveFormCanvasView.isHidden = true
            waveFormView.isHidden = false
            record_start_stop_button.isEnabled = false
            recordFile_play_PauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        case .afterPlaying:
            record_start_stop_button.isEnabled = true
            recordFile_play_PauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        default:
            break
        }
    }
    
    @objc func tabForward(){
        playVoiceManager.forwardOrBackWard(forward: true)
    }
    
    @objc func tabBackward(){
        playVoiceManager.forwardOrBackWard(forward: false)
    }
    
    @objc func tapButton(){
        if playVoiceManager.isPlay{
            playVoiceManager.playOrPauseAudio()
            updateUI(when: .afterPlaying)
        }else{
            playVoiceManager.playOrPauseAudio()
            updateUI(when: .beforePlaying)
        }
    }
    
}

extension RecordVoiceViewController : DrawWaveFormManagerDelegate{
    
    func moveWaveFormView(_ step: CGFloat){
        UIView.animate(withDuration: 1/14, animations: {
            self.waveFormCanvasView.transform = CGAffineTransform(translationX: -step, y: 0)
        })
    }
    
    func resetWaveFormView(){
        self.waveFormCanvasView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}

extension RecordVoiceViewController : RecordVoiceManagerDelegate{
    func updateCurrentTime(_ currentTime : TimeInterval){
        self.progressTimeLabel.text = currentTime.getStringTimeInterval()
    }
}

extension RecordVoiceViewController : PlayVoiceDelegate{
    func displayCurrentTime(_ currentPosition: AVAudioFramePosition, _ audioLengthSamples: AVAudioFramePosition, _ audioFileLengthSecond: Double){
        var currentTime : Double
        if currentPosition <= 0 {
            currentTime = 0
        }else if currentPosition >= audioLengthSamples {
            currentTime = audioFileLengthSecond
        }else{
            currentTime = (Double(currentPosition)/Double(audioLengthSamples)) * audioFileLengthSecond
        }
        self.progressTimeLabel.setText(currentTime)
    }
    
    func displayWaveForm(to currentPosition: AVAudioFramePosition, in audioLengthSamples: AVAudioFramePosition){
        var newX : CGFloat
        if currentPosition <= 0 {
            newX = 0
        }else if currentPosition >= audioLengthSamples {
            newX = self.waveFormView.imageView.image?.size.width ?? 0
        }else{
            newX = (self.waveFormView.imageView.image?.size.width ?? 0) * CGFloat(currentPosition) / CGFloat(audioLengthSamples)
        }
        self.waveFormView.imageView.transform = CGAffineTransform(translationX: -newX, y: 0)
    }
    
    func playEndTime(){
        playVoiceManager.isPlay = false
        DispatchQueue.main.async {
            self.updateUI(when: .afterPlaying)
        }
    }
}



