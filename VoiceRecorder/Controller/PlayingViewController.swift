//
//  PlaingViewController.swift
//  VoiceRecorder
//
//  Created by Jinhyang Kim on 2022/06/27.
//

import UIKit
import AVFoundation

class PlayingViewController: UIViewController {
    
    static let identifier: String = "PlayingViewController"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerControlView: UIStackView!
    @IBOutlet weak var volumeControlSlider: UISlider!
    @IBOutlet weak var voiceChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var waveImageView: UIImageView!
    @IBOutlet weak var positionProgressView: UIProgressView!
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let audioPlayer = AVAudioPlayerNode()
    let pitchControl = AVAudioUnitTimePitch()
    var player : AVAudioPlayer?
    var fileName : String?
    var fileURL : URL?
    var timer : Timer?
    var file = AVAudioFile()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = fileName
        
    }
    
    func play(_ url: URL) {
        do {
            file = try AVAudioFile(forReading: url)
            
            if !(timer?.isValid == true){
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            }
            if audioPlayer.isPlaying == false {
                engine.attach(audioPlayer)
                engine.attach(pitchControl)
                engine.attach(speedControl)
                
                
                engine.connect(audioPlayer,
                               to: speedControl,
                               format: nil)
                engine.connect(speedControl,
                               to: pitchControl,
                               format: nil)
                engine.connect(pitchControl,
                               to: engine.mainMixerNode,
                               format: nil)
                audioPlayer.scheduleFile(file,
                                         at: nil)
                
                try engine.start()
                audioPlayer.play()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            else {
                audioPlayer.pause()
    //            player?.prepareToPlay()
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } catch {
            print("error catch")
        }
    }
    
    func showWaveForm() {
        let scale = UIScreen.main.scale;
        let imageSizeInPixel =  CGSize(width:waveImageView.bounds.width * scale,height:waveImageView.bounds.height * scale);
        generateWaveformImage(audioURL: fileURL!, imageSizeInPixel: imageSizeInPixel, waveColor: UIColor.gray) {[weak self] (waveFormImage) in
            if let waveFormImage = waveFormImage {
                self?.waveImageView.image = waveFormImage;
            }
        }
    }
 
//    func playSound() {
//        if !(timer?.isValid == true){
//            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//        }
//        if audioPlayer.isPlaying == false {
//            audioPlayer.play()
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        }
//        else {
//            audioPlayer.pause()
////            player?.prepareToPlay()
//            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        }
//    }
    
    @objc func updateTimer() {
        
        positionProgressView.progress = Float(audioPlayer.current) / Float(file.duration)
        
        if audioPlayer.isPlaying == true {
            if audioPlayer.current >= file.duration {
                audioPlayer.stop()
                engine.stop()
                positionProgressView.progress = 0
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                return
            }

        }
    }
    
    @IBAction func pressVoiceChangeButton(_ sender: UISegmentedControl) {
        let selectedVoiceValue = sender.selectedSegmentIndex

        switch selectedVoiceValue {
        case 0:
            pitchControl.pitch = 0
        case 1:
            pitchControl.pitch = 2400 * 0.5
        case 2:
            pitchControl.pitch = 500 * -0.5
        default:
            pitchControl.pitch = 0
        }
    }
    
    @IBAction func PressPlayButton(_ sender: UIButton) {
//        playSound()
        play(fileURL!)
    }
    
    @IBAction func ControlVolumeSlider(_ sender: UISlider) {
        audioPlayer.volume = volumeControlSlider.value
    }
    
    @IBAction func PressPrevButton(_ sender: UIButton) {
        if audioPlayer.isPlaying == true {
//            print("audioPlayer.current:\(audioPlayer.current)")
//            audioPlayer.current -= 5
        }
    }
    
    @IBAction func PressNextButton(_ sender: UIButton) {
        if audioPlayer.isPlaying == true {
//            audioPlayer.current += 5
        }
    }
}

extension PlayingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        positionProgressView.progress = 0.0
        timer?.invalidate()
    }
}
