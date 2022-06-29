//
//  PlayButtonView.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/06/29.
//

import UIKit

class PlayButtonView: UIView {

  let stackView = UIStackView()
  let backButton = UIButton()
  let playButton = UIButton()
  let forwordButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("Custom Button Error")
  }

  func setupView() {
    stackView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(stackView)
    setBuputton()
    setupStackView()
  }

  private func setBuputton() {
    var imageConfig = UIImage.SymbolConfiguration(pointSize: 35)

    backButton.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
    playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    forwordButton.setImage(UIImage(systemName: "goforward.5"), for: .normal)

    [backButton, playButton, forwordButton].forEach {
      $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
  }

  private func setupStackView() {
    stackView.spacing = 18
    stackView.distribution = .fillEqually
    [backButton, playButton, forwordButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.backgroundColor = .white
      stackView.addArrangedSubview($0)
    }
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: self.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
}
