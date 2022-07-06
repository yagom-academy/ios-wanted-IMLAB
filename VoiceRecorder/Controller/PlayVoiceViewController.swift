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
    var firebaseStorageManager : FirebaseStorageManager!
    
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
    
    var selectedPitchSegment : UISegmentedControl = {
        let selectedPitchSegment = UISegmentedControl(items: ["일반 목소리","아기목소리","할아버지목소리"])
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
    
    let volumeTextLabel : UILabel = {
        let volumeTextLabel = UILabel()
        volumeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeTextLabel.text = "volume"
        return volumeTextLabel
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
            fileNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: standardConstant),
            
            waveFormBackgroundView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: waveFormTopAnchorMP),
            waveFormBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveFormBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: waveFormHeightMP),
            waveFormBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            waveFormImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            waveFormImageView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: waveFormTopAnchorMP),
            waveFormImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            waveFormImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: waveFormHeightMP),
            
            verticalLineView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            verticalLineView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: waveFormTopAnchorMP),
            verticalLineView.widthAnchor.constraint(equalTo: view.widthAnchor),
            verticalLineView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: waveFormHeightMP),
            
            selectedPitchSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedPitchSegment.topAnchor.constraint(equalTo: waveFormImageView.bottomAnchor, constant: standardConstant),
            
            volumeTextLabel.topAnchor.constraint(equalTo: selectedPitchSegment.bottomAnchor, constant: standardConstant),
            volumeTextLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: standardWidthMP),
            volumeTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            volumeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeSlider.topAnchor.constraint(equalTo: volumeTextLabel.bottomAnchor),
            volumeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: standardWidthMP),
            
            playAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAndPauseButton.centerYAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: standardConstant),
                        
        ])
        view.bringSubviewToFront(waveFormImageView)
        view.bringSubviewToFront(verticalLineView)
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
        playVoiceManager.closeAudio()
    }
    
    deinit{
        print("CLOSE PLAYVOICE")
    }
}

extension PlayVoiceViewController : FirebaseStorageManagerDelegate{
    func downloadComplete(url : URL) {
        waveFormImageView.load(url: url) {
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
    
    func displayWaveForm(to currentPosition : AVAudioFramePosition, in audioLengthSamples : AVAudioFramePosition) {
        print("currentPosition: \(currentPosition), audioLengthSamples: \(audioLengthSamples)")
        let newX = (self.waveFormImageView.image?.size.width ?? 0) * CGFloat(currentPosition) / CGFloat(audioLengthSamples)
        self.waveFormImageView.transform = CGAffineTransform(translationX: -newX, y: 0)
    }
}

extension UIImageView{
    func load(url : URL , completion : @escaping ()->Void){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        let resizedImage = image.aspectFitImage(inRect: self?.bounds ?? CGRect(x: 0, y: 0, width: 10, height: 10))
                        self?.image = resizedImage
                        completion()
                    }
                }
            }
        }
    }
}


extension UIImage {
    func aspectFitImage(inRect rect: CGRect) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let scaleFactor = rect.size.height / height

        UIGraphicsBeginImageContext(CGSize(width: width * scaleFactor, height: height * scaleFactor))
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: width * scaleFactor, height: height * scaleFactor))

        defer {
            UIGraphicsEndImageContext()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
