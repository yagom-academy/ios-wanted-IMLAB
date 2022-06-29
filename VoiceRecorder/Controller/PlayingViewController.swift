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
    
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialPlay()
    }
    func initialPlay() {
        let url = Bundle.main.url(forResource: "마음을 드려요(MR) - IU", withExtension: "mp3")
        // local url 가져와야함
        if let findUrl = url {
            do {
                player = try AVAudioPlayer(contentsOf: findUrl)
                player?.prepareToPlay() // 실제 호출과 기기의 플레이 간의 딜레이를 줄여줌
            }
            catch {
                print(error)
            }
        }
    }
    
    func playSound() {
        if !(player?.isPlaying ?? false) {
            player?.play()
        }
        else {
            player?.pause()
            player?.prepareToPlay()
        }
    }
    
    @IBAction func PressPlayButton(_ sender: UIButton) {
        playSound()
    }
    
}
