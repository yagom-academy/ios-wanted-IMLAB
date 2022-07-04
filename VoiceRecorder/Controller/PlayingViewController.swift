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
    
    var player : AVAudioPlayer?
    var fileName : String?
    var fileURL : URL?
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialPlay()
        titleLabel.text = fileName
        
    }
    
    func initialPlay() {
        if let url = fileURL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                showWaveForm()
                player?.prepareToPlay() // 실제 호출과 기기의 플레이 간의 딜레이를 줄여줌
            }
            catch {
                print(error)
            }
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
    
    func playSound() {
        if !(timer?.isValid == true){
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        if player?.isPlaying == false {
            player?.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        else {
            player?.pause()
            player?.prepareToPlay()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func updateTimer() {
        if player?.isPlaying == true {
            let digit : Float = pow(10, 2)
            let currentTIme = round(Float(player?.currentTime ?? 0.0) * digit) / digit // 소수점 3번째 자리에서 반올림
            let duration = round(Float(player?.duration ?? 0.0) * digit) / digit
            positionProgressView.progress = currentTIme / duration
        }
    }
    
    @IBAction func PressPlayButton(_ sender: UIButton) {
        playSound()
    }
    
    @IBAction func ControlVolumeSlider(_ sender: UISlider) {
        player?.volume = volumeControlSlider.value
    }
    
    @IBAction func PressPrevButton(_ sender: UIButton) {
        if player?.isPlaying == true {
            player?.currentTime -= 5
        }
    }
    
    @IBAction func PressNextButton(_ sender: UIButton) {
        if player?.isPlaying == true {
            player?.currentTime += 5
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
