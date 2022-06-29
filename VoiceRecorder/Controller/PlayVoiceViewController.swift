//
//  PlayVoiceViewController.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit

class PlayVoiceViewController: UIViewController {
    
    var voiceRecordViewModel : VoiceRecordViewModel!

    var playAndPauseButton: UIButton = {
        let playAndPauseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playAndPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        playAndPauseButton.setPreferredSymbolConfiguration(.init(pointSize: 50), forImageIn: .normal)
        playAndPauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return playAndPauseButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        autolayOut()
    }
    
    func setView(){
        self.view.addSubview(playAndPauseButton)
    }
    
    func autolayOut(){
        NSLayoutConstraint.activate([
            playAndPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAndPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func tapButton(){
        print("tap button")
    }
}
