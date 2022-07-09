//
//  RecordingViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

import AVFAudio
import AVFoundation

final class RecordingViewController: BaseViewController {

    private let recordingView = RecordingView()

    private var isRecording: Bool = false

    var viewModel: RecordingViewModel?
    var recordPermissionManager: RecordPermissionManageable?

    override func loadView() {
        self.view = recordingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviewTarget()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.recordURL.removeAllCachedResourceValues()
    }

    private func record() {
        recordPermissionManager?.requestMicrophoneAccess { [weak self] allowed in
            guard let self = self else { return }
            if allowed {
                self.isRecording.toggle()
                self.showPlayButton()
                self.viewModel?.allowed()
                if self.isRecording {
                    self.viewModel?.record()
                } else {
                    self.upload()
                }
            } else {
                self.okAlert(title: "녹음 권한 설정을 허용해주세요 🎙")
            }
        }
    }
    
    private func showPlayButton() {
        if isRecording {
            UIView.animate(withDuration: 0.1) {
                self.alphaOfButtons(value: 0)
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.alphaOfButtons(value: 1)
            }
        }
    }
    
    private func alphaOfButtons(value:CGFloat){
        [recordingView.goforward5Button,recordingView.startButton,recordingView.goBackward5Button].forEach {
            $0.alpha = value
            $0.isEnabled = value == 0 ? false : true
        }

    }

    @objc private func recordingButtonTapped() {
        record()
    }
    
    @objc private func playButtonTapped(sender: UIButton) {
        
        sender.setImage(UIImage(systemName: "pause"), for: .normal)
    }

    private func upload() {
        guard let recordURL = self.viewModel?.recordURL else { return }
        self.alert { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.upload(from: recordURL)
            self.viewModel?.download()
            self.viewModel?.recordingFinished()
        } cancelHandler: { _ in
            print("cancel record saving")
        }
        self.viewModel?.stopRecording()
    }

    private func addSubviewTarget() {
        recordingView.recordButton.addTarget(self, action: #selector(recordingButtonTapped), for: .touchUpInside)
        recordingView.startButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
}
