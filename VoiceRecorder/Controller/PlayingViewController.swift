//
//  PlayingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/07/02.
//

import UIKit

class PlayingViewController: UIViewController {
    
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    var selectedFileInfo: RecordModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        
    }
}
