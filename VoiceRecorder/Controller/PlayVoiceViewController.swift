//
//  PlayVoiceViewController.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit

class PlayVoiceViewController: UIViewController {
    
    var playVoiceManager : PlayVoiceManager!
    var playVoiceViewModel : PlayVoiceViewModel!
    var firebaseStorageManager : FirebaseStorageManager!
    
    var soundWaveImageView : UIImageView = {
        let soundWaveImageView = UIImageView()
        soundWaveImageView.translatesAutoresizingMaskIntoConstraints = false
        soundWaveImageView.contentMode = .scaleAspectFit
        return soundWaveImageView
    }()
    
    var selectedPitchSegment : UISegmentedControl = {
        let selectedPitchSegment = UISegmentedControl(items: ["일반 목소리","아기목소리","할아버지목소리"])
        selectedPitchSegment.translatesAutoresizingMaskIntoConstraints = false
        selectedPitchSegment.selectedSegmentIndex = 0
        selectedPitchSegment.addTarget(self, action: #selector(selectPitch(_:)), for: .valueChanged)
        return selectedPitchSegment
    }()
    
    var timeControlButtonStackView : UIStackView = {
        let timeControlButtonStackView = UIStackView()
        timeControlButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        timeControlButtonStackView.axis = .horizontal
        timeControlButtonStackView.spacing = 20
        return timeControlButtonStackView
    }()

    var playAndPauseButton: UIButton = {
        let playAndPauseButton = UIButton()
        playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playAndPauseButton.setPreferredSymbolConfiguration(.init(pointSize: 30), forImageIn: .normal)
        playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        playAndPauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return playAndPauseButton
    }()
    
    var forwardFive: UIButton = {
        let forwardFive = UIButton()
        forwardFive.translatesAutoresizingMaskIntoConstraints = false
        forwardFive.setPreferredSymbolConfiguration(.init(pointSize: 30), forImageIn: .normal)
        forwardFive.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        forwardFive.addTarget(self, action: #selector(tabForward), for: .touchUpInside)
        return forwardFive
    }()
    
    var backwardFive: UIButton = {
        let backwardFive = UIButton()
        backwardFive.translatesAutoresizingMaskIntoConstraints = false
        backwardFive.setPreferredSymbolConfiguration(.init(pointSize: 30), forImageIn: .normal)
        backwardFive.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        backwardFive.addTarget(self, action: #selector(tabBackward), for: .touchUpInside)
        return backwardFive
    }()
    
    let volumeSlider : UISlider = {
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
        fileNameLabel.font = .boldSystemFont(ofSize: 20)
        return fileNameLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        autolayOut()
        //순환참조 발생 주의
        firebaseStorageManager.delegate = self
        playAndPauseButton.isEnabled = false
        firebaseStorageManager.downloadRecordFile(fileName: "\(playVoiceViewModel.voiceRecordViewModel.fileName)@\(playVoiceViewModel.voiceRecordViewModel.fileLength)", imageFileName: "\(playVoiceViewModel.voiceRecordViewModel.fileName)")
    }
    
    func setView(){
        self.view.addSubview(fileNameLabel)
        self.view.addSubview(soundWaveImageView)
        self.view.addSubview(selectedPitchSegment)
        self.view.addSubview(volumeSlider)
        self.view.addSubview(timeControlButtonStackView)
        for item in [ backwardFive, playAndPauseButton, forwardFive ]{
            timeControlButtonStackView.addArrangedSubview(item)
        }
    }
    
    func autolayOut(){
        NSLayoutConstraint.activate([
            
            fileNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fileNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            soundWaveImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            soundWaveImageView.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 30),
            soundWaveImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            selectedPitchSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedPitchSegment.topAnchor.constraint(equalTo: soundWaveImageView.bottomAnchor, constant: 30),
            
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: selectedPitchSegment.bottomAnchor, constant: 30),
            volumeSlider.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            
            playAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAndPauseButton.centerYAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 30),
        ])
    }
    
    func setUIText(){
        fileNameLabel.text = playVoiceViewModel.voiceRecordViewModel.fileName
        fileNameLabel.font = .boldSystemFont(ofSize: self.view.bounds.width / 25)
        volumeSlider.setValue(playVoiceManager.getVolume(), animated: true)
    }
    
    @objc func selectPitch(_ sender : UISegmentedControl){
        playVoiceManager.setPitch(pitch: SoundPitch(rawValue: sender.selectedSegmentIndex)!)
    }
    
    @objc func tapButton(){
        if playVoiceManager.isPlay{
            playVoiceManager.stopAudio()
            playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }else{
            playVoiceManager.playAudio()
            playAndPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    @objc func tabForward(){
        playVoiceManager.forwardFiveSecond()
    }
    
    @objc func tabBackward(){
        playVoiceManager.backwardFiveSecond()
    }
    
    @objc func slideVolumeButton(_ sender : UISlider){
        playVoiceManager.setVolume(volume: sender.value)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        playVoiceManager.stopAudio()
    }
    
    deinit{
        print("CLOSE PLAYVOICE")
    }
}

extension PlayVoiceViewController : FirebaseStorageManagerDelegate{
    func downloadComplete(url : URL) {
        soundWaveImageView.load(url: url) {
            self.playAndPauseButton.isEnabled = true
        }
        playVoiceManager = PlayVoiceManager()
        playVoiceManager.delegate = self
        setUIText()
    }
}

extension PlayVoiceViewController : PlayVoiceDelegate{
    func playEndTime() {
        playVoiceManager.isPlay = false
        DispatchQueue.main.async {
            self.playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
        
    }
}

extension UIImageView{
    func load(url : URL , completion : @escaping ()->Void){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                        completion()
                    }
                }
            }
        }
    }
}
