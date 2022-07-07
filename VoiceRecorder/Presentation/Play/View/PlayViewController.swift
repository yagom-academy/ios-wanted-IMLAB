//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayViewController: BaseViewController {
    
    private let playView = PlayView()
    var viewModel: PlayViewModel?
    
    private var isPlaying = false
    
    override func loadView() {
        self.view = playView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        playView.goBackrward5Button.addTarget(self, action: #selector(move5SecondsBackward), for: .touchUpInside)
        
        playView.goforward5Button.addTarget(self, action: #selector(move5SecondsForward), for: .touchUpInside)
        
        playView.slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .touchUpInside)
        
        playView.segmentedContoller.addTarget(self, action: #selector(segmentedControlValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc private func startButtonTapped(sender: UIButton){
        if isPlaying {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            viewModel?.pause()
        } else {
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            viewModel?.play()
        }
        isPlaying.toggle()
    }
    
    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        viewModel?.changePitch(to: sender.selectedSegmentIndex)
    }
    
    @objc private func sliderValueChanged(sender: UISlider) {
        viewModel?.controlVolume(to: sender.value)
    }
    
    @objc private func move5SecondsForward() {
        viewModel?.move(seconds: 5)
    }
    
    @objc private func move5SecondsBackward() {
        viewModel?.move(seconds: -5)
    }

}
