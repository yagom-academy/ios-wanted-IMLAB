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
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var playerControlView: UIStackView!
    @IBOutlet weak var volumeControlSlider: UISlider!
    @IBOutlet weak var voiceChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playButton: UIButton!
    
    
    var player : AVAudioPlayer?
    var fileName : String?
    var fileURL : URL?
    
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
                player?.prepareToPlay() // 실제 호출과 기기의 플레이 간의 딜레이를 줄여줌
            }
            catch {
                print(error)
            }
        }
    }
    
    func playSound() {
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
    
    @IBAction func PressPlayButton(_ sender: UIButton) {
        playSound()
    }
    
}

extension PlayingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
}
