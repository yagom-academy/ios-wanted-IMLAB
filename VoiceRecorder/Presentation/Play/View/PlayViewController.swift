//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayViewController: BaseViewController {

    var viewModel: PlayViewModel?
    private let playView = PlayView()
    private var isPlaying = false
    
    override func loadView() {
        self.view = playView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViewTarget()
        generateWaveForm()
        bindWithViewModel()
    }
    
    private func addSubViewTarget() {
        playView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        playView.goBackrward5Button.addTarget(self, action: #selector(move5SecondsBackward), for: .touchUpInside)
        playView.goforward5Button.addTarget(self, action: #selector(move5SecondsForward), for: .touchUpInside)
        playView.slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .touchUpInside)
        playView.segmentedContoller.addTarget(self, action: #selector(segmentedControlValueChanged(sender:)), for: .valueChanged)
    }
    
    private func bindWithViewModel() {
        guard let duration = viewModel?.audioInformation.duration else { return }
        let audioWaveScrollView = playView.audioWaveScrollView
        
        viewModel?.currentTime.bind { currentTime in
            if currentTime < duration {
                UIView.animate(withDuration: 1) {
                    audioWaveScrollView.contentOffset.x
                    = (audioWaveScrollView.contentSize.width - (UIScreen.main.bounds.width / 2)) * (currentTime / duration)
                }
            } else if currentTime == duration {
                DispatchQueue.main.async {
                    self.playView.startButton.setImage(UIImage(systemName: "play"), for: .normal)
                }
                self.viewModel?.pause()
            }
        }
    }
    
    private func generateWaveForm() {
        guard let fileURL = viewModel?.audioInformation.fileURL else { return }
        guard let duration = viewModel?.audioInformation.duration else { return }
        
        let image = WaveFormGenerator().generateWaveImage(
            from: fileURL,
            in: CGSize(
                width: UIScreen.main.bounds.width * duration / 3.5,
                height: UIScreen.main.bounds.width * 0.4
            )
        )
        playView.audioWaveImageView.image = image
    }
}

// MARK: - AddTarget selector methods

extension PlayViewController {

    @objc private func startButtonTapped(sender: UIButton) {
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
