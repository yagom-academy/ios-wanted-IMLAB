//
//  PlayVoiceViewController.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit

class PlayVoiceViewController: UIViewController {
    
    var playVoiceManager : PlayVoiceManager!
    var voiceRecordViewModel : VoiceRecordViewModel!
    
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
        setUIText()
        //순환참조 발생 주의
    }
    
    func setView(){
        self.view.addSubview(fileNameLabel)
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
            
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: view.centerYAnchor),
            volumeSlider.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            
            playAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAndPauseButton.centerYAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 30),
        ])
    }
    
    func setUIText(){
        fileNameLabel.text = voiceRecordViewModel.fileName
        fileNameLabel.font = .boldSystemFont(ofSize: self.view.bounds.width / 25)
        //volumeSlider.setValue(playVoiceManager.getVolume(), animated: true)
    }
    
    @objc func tapButton(){
        if playVoiceManager.isPlay{
            //playVoiceManager.stopAudio()
            playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }else{
            playVoiceManager.playAudio()
            playAndPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    @objc func tabForward(){
        //playVoiceManager.forwardFiveSecond()
    }
    
    @objc func tabBackward(){
        //playVoiceManager.backwardFiveSecond()
    }
    
    @objc func slideVolumeButton(_ sender : UISlider){
        //playVoiceManager.setVolume(volume: sender.value)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //playVoiceManager.stopAudio()
    }
}

extension PlayVoiceViewController : PlayVoiceDelegate{
    func playEndTime() {
        tapButton()
    }
}
