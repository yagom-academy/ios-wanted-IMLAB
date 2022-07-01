//
//  PlayViewController.swift
//  VoiceRecorder
//

import UIKit

class PlayViewController: UIViewController {
    
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var voiceChangeSegment: UISegmentedControl!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var recordFile: RecordModel?
    var player: AudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpPlayer()
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        player?.play()
    }
    
    func configureUI() {
        guard let recordFile = recordFile else { return }
        dateTitleLabel.text = String(recordFile.name.dropLast(4))
    }
    
    func setUpPlayer() {
        guard let recordFile = recordFile else { return }
        player = recordFile.audioPlayer
    }

}
