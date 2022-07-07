//
//  PlayVoiceViewController.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit
import AVFoundation

class PlayVoiceViewController: UIViewController {
    
    var playVoiceManager : PlayVoiceManager!
    var playVoiceViewModel : PlayVoiceViewModel!
    var firebaseDownloadManager : FirebaseStorageDownloadManager!
    
    let progressTimeLabel : TimeLabel = {
        let progressTimeLabel = TimeLabel()
        progressTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return progressTimeLabel
    }()
    
    var verticalLineView : VerticalLineView = {
        let verticalLineView = VerticalLineView()
        verticalLineView.translatesAutoresizingMaskIntoConstraints = false
        return verticalLineView
    }()
    
    var waveFormImageView : WaveFormImageView = {
        let waveFormImageView = WaveFormImageView(frame: CGRect())
        waveFormImageView.translatesAutoresizingMaskIntoConstraints = false
        return waveFormImageView
    }()
    
    lazy var selectedPitchSegment : UISegmentedControl = {
        let selectedPitchSegment = UISegmentedControl(items: [CNS.pitch.normal, CNS.pitch.baby, CNS.pitch.grandfather])
        selectedPitchSegment.translatesAutoresizingMaskIntoConstraints = false
        selectedPitchSegment.selectedSegmentIndex = 0
        selectedPitchSegment.addTarget(self, action: #selector(selectPitch(_:)), for: .valueChanged)
        return selectedPitchSegment
    }()
    
    var waveFormBackgroundView : UIView = {
        let waveFormBackgroundView = UIView()
        waveFormBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        waveFormBackgroundView.backgroundColor = .systemGray6
        return waveFormBackgroundView
    }()
    
    var timeControlButtonStackView : UIStackView = {
        let timeControlButtonStackView = UIStackView()
        timeControlButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        timeControlButtonStackView.axis = .horizontal
        timeControlButtonStackView.spacing = 20
        return timeControlButtonStackView
    }()

    lazy var playAndPauseButton: UIButton = {
        let playAndPauseButton = UIButton()
        playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playAndPauseButton.setPreferredSymbolConfiguration(.init(pointSize: CNS.size.playButton), forImageIn: .normal)
        playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        playAndPauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return playAndPauseButton
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
    
    let volumeTextLabel : UILabel = {
        let volumeTextLabel = UILabel()
        volumeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeTextLabel.text = "volume"
        return volumeTextLabel
    }()
    
    lazy var volumeSlider : UISlider = {
        let volumeSlider = UISlider()
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        volumeSlider.addTarget(self, action: #selector(slideVolumeButton(_:)), for: .allTouchEvents)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        return volumeSlider
    }()
    
    var fileNameLabel : UILabel = {
        let fileNameLabel = UILabel()
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return fileNameLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        autolayOut()
        firebaseDownloadManager.delegate = self
        playAndPauseButton.isEnabled = false
        firebaseDownloadManager.downloadFile()
    }
    
    func setView(){
        self.view.addSubview(fileNameLabel)
        self.view.addSubview(progressTimeLabel)
        self.view.addSubview(verticalLineView)
        self.view.addSubview(waveFormImageView)
        self.view.addSubview(waveFormBackgroundView)
        self.view.addSubview(selectedPitchSegment)
        self.view.addSubview(volumeTextLabel)
        self.view.addSubview(volumeSlider)
        self.view.addSubview(timeControlButtonStackView)
        for item in [ backwardFive, playAndPauseButton, forwardFive ]{
            timeControlButtonStackView.addArrangedSubview(item)
        }
    }
    
    func autolayOut(){
        NSLayoutConstraint.activate([
            
            fileNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fileNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: CNS.autoLayout.standardConstant),
            
            progressTimeLabel.bottomAnchor.constraint(equalTo: waveFormImageView.topAnchor, constant: -CNS.autoLayout.minConstant),
            progressTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            waveFormBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveFormBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            waveFormBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormBackgroundView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            waveFormImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            waveFormImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            waveFormImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            verticalLineView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            verticalLineView.widthAnchor.constraint(equalTo: view.widthAnchor),
            verticalLineView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CNS.autoLayout.waveFormHeightMP),
            verticalLineView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            
            selectedPitchSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedPitchSegment.topAnchor.constraint(equalTo: waveFormImageView.bottomAnchor, constant: CNS.autoLayout.standardConstant),
            
            volumeTextLabel.topAnchor.constraint(equalTo: selectedPitchSegment.bottomAnchor, constant: CNS.autoLayout.standardConstant),
            volumeTextLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CNS.autoLayout.standardWidthMP),
            volumeTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: volumeTextLabel.bottomAnchor),
            volumeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CNS.autoLayout.standardWidthMP),
            
            playAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAndPauseButton.centerYAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: CNS.autoLayout.standardConstant),
                        
        ])
        view.bringSubviewToFront(waveFormImageView)
        view.bringSubviewToFront(verticalLineView)
    }
    
    func setUIText(){
        fileNameLabel.text = playVoiceViewModel.voiceRecordViewModel.fileName
        fileNameLabel.font = .boldSystemFont(ofSize: CNS.size.fileName)
        volumeSlider.setValue(playVoiceManager.getVolume(), animated: true)
    }
    
    @objc func selectPitch(_ sender : UISegmentedControl){
        playVoiceManager.setPitch(pitch: SoundPitch(rawValue: sender.selectedSegmentIndex)!)
    }
    
    @objc func tapButton(){
        if playVoiceManager.isPlay{
            playVoiceManager.playOrPauseAudio()
            playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }else{
            playVoiceManager.playOrPauseAudio()
            playAndPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    @objc func tabForward(){
        playVoiceManager.forwardOrBackWard(forward: true)
    }
    
    @objc func tabBackward(){
        playVoiceManager.forwardOrBackWard(forward: false)
    }
    
    @objc func slideVolumeButton(_ sender : UISlider){
        playVoiceManager.setVolume(volume: sender.value)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !playVoiceViewModel.isDownloading{
            print("close audio")
            playVoiceManager.closeAudio()
        }else{
            print("Cancel download")
            firebaseDownloadManager.cancelDownload()
        }
    }
    
    deinit{
        print("CLOSE PLAYVOICE")
    }
}

extension PlayVoiceViewController : FirebaseDownloadManagerDelegate{
    func downloadComplete(url: URL) {
        waveFormImageView.load(url: url) { [weak self] in
            self?.playAndPauseButton.isEnabled = true
            self?.playVoiceViewModel.isDownloading = false
        }
        playVoiceManager = PlayVoiceManager()
        playVoiceManager.delegate = self
        setUIText()
    }
    
   
}

extension PlayVoiceViewController : PlayVoiceDelegate{
    func displayCurrentTime(_ currentPosition: AVAudioFramePosition, _ audioLengthSamples: AVAudioFramePosition, _ audioFileLengthSecond: Double) {
        var currentTime : Double
        if currentPosition <= 0 {
            currentTime = 0
        } else if currentPosition >= audioLengthSamples {
            currentTime = audioFileLengthSecond
        } else {
            currentTime = (Double(currentPosition)/Double(audioLengthSamples)) * audioFileLengthSecond
        }
        self.progressTimeLabel.setText(currentTime)
    }
    
    
    func playEndTime() {
        playVoiceManager.isPlay = false
        DispatchQueue.main.async {
            self.playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    func displayWaveForm(to currentPosition : AVAudioFramePosition, in audioLengthSamples : AVAudioFramePosition) {
        var newX : CGFloat
        if currentPosition <= 0 {
            newX = 0
        } else if currentPosition >= audioLengthSamples {
            newX = self.waveFormImageView.image?.size.width ?? 0
        } else {
            newX = (self.waveFormImageView.image?.size.width ?? 0) * CGFloat(currentPosition) / CGFloat(audioLengthSamples)
        }
        self.waveFormImageView.transform = CGAffineTransform(translationX: -newX, y: 0)
    }
}





