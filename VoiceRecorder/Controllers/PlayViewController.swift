//
//  PlayViewController.swift
//  VoiceRecorder
//

import UIKit

class PlayViewController: UIViewController {
    
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var voiceChangeSegment: UISegmentedControl!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    var recordFile: RecordModel?
    var player: AudioPlayer?
    var isPlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpPlayer()
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        player?.seek(-5)
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        player?.seek(5)
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            player?.stop()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            player?.play()
        }
        isPlay = !isPlay
    }
    
    func configureUI() {
        guard let recordFile = recordFile else { return }
        dateTitleLabel.text = String(recordFile.name.dropLast(4))
    }
    
    func setUpPlayer() {
        guard let recordFile = recordFile else { return }
        player = recordFile.audioPlayer
        player?.didFinish = {
            self.player?.stop()
            self.playButton.setImage(Icon.play.image, for: .normal)
            self.isPlay = false
        }
    }

}
