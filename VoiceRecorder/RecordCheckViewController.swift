//
//  RecordCheckViewController.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/06/28.
//

import UIKit
import AVFAudio
import AVFoundation

class RecordCheckViewController: UIViewController {
    
    var audioReorder : AVAudioRecorder!
    
    // let session = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brown
    }
    
}
