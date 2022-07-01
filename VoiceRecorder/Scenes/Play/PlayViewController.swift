//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/06/29.
//

import AVFoundation
import UIKit

class PlayViewController: UIViewController {

  let playView = PlayView()
  var audio: Audio?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    setupAudio()
    bind()
    setupAction()
  }

  func setupView() {
    view.backgroundColor = .white
    playView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playView)
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      playView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      playView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      playView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  // MARK: - Test를 위해서 네트워크 통신 결과 URL 값을 바로 넣어주는 상태
  func setupAudio() {
//    guard
//      let fileURL = Bundle.main.url(
//        forResource: "Til I Hear'em Say (Instrumental) - NEFFEX",
//        withExtension: "mp3"
//      )
//    else {
//      print("음원없음")
//      return
//    }

    let testURL = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/voicerecorder-7fa55.appspot.com/o/testAudio.mp3?alt=media&token=6e64aacd-7b5f-457f-8ca3-6859cc6891d9")!
    let fileManager = RecordFileManager()
    fileManager.saveRecordFile(recordName: "test", file: testURL)
    guard let file = fileManager.loadRecordFile("test") else { return }
    audio = Audio(file)
  }

  func bind() {
    audio?.playerProgress.bind({ value in
      self.playView.recorderSlider.value = Float(value)
    })

    audio?.playerTime.bind({ time in
      self.playView.totalTimeLabel.text = time.remainingText
      self.playView.spendTimeLabel.text = time.elapsedText
    })

    audio?.isPlaying.bind({ isplay in
      if isplay == false {
        self.playView.playButton.playButton.setImage(
          UIImage(systemName: "play.circle.fill"),
          for: .normal
        )
      } else {
        self.playView.playButton.playButton.setImage(
          UIImage(systemName: "pause.circle.fill"),
          for: .normal
        )
      }
    })
  }

  func setupAction() {
    playView.playButton.backButton.addTarget(
      self,
      action: #selector(backButtonclicked),
      for: .touchUpInside
    )
    playView.playButton.playButton.addTarget(
      self,
      action: #selector(playButtonClicked),
      for: .touchUpInside
    )
    playView.playButton.forwordButton.addTarget(
      self,
      action: #selector(forwardButtonClicked),
      for: .touchUpInside
    )
    playView.segmentControl.addTarget(
      self,
      action: #selector(segconChanged(segcon:)),
      for: .valueChanged
    )
    playView.recorderSlider.addTarget(
      self,
      action: #selector(sliderValueChanged(_:)),
      for: .valueChanged
    )
  }

  @objc
  func playButtonClicked() {
    print(#function)
    audio?.playOrPause()
  }

  @objc
  func backButtonclicked() {
    guard audio != nil else { return }
    audio?.skip(forwards: false)
  }

  @objc
  func forwardButtonClicked() {
    guard audio != nil else { return }
    audio?.skip(forwards: true)
  }

  @objc
  func segconChanged(segcon: UISegmentedControl) {
    guard audio != nil else { return }
    audio?.changePitch(segcon.selectedSegmentIndex)
  }

  @objc
  func sliderValueChanged(_ sender: UISlider) {
    audio?.seek(to: sender.value)
  }

}
