//
//  PlayContentView.swift
//  VoiceRecorder
//
//  Created by rae on 2022/07/06.
//

import UIKit

class PlayContentView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let progressTimeView = ProgressTimeView()
    
    let playSeekStackView = PlaySeekStackView()
    
    private let minVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "speaker.fill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let maxVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "speaker.3.fill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.setValue(0.5, animated: false)
        return slider
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minVolumeImageView, volumeSlider, maxVolumeImageView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    let pitchSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["일반 목소리", "아기 목소리", "할아버지 목소리"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PlayContentView {
    func configure() {
        addSubViews()
        makeConstraints()
    }
    
    func addSubViews() {
        [titleLabel, progressTimeView, pitchSegmentedControl, playSeekStackView, volumeStackView].forEach {
            addSubview($0)
        }
    }
    
    func makeConstraints() {
        [titleLabel, progressTimeView, pitchSegmentedControl, playSeekStackView, volumeStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0),
            
            progressTimeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.0),
            progressTimeView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressTimeView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressTimeView.heightAnchor.constraint(equalToConstant: 32.0),
            
            pitchSegmentedControl.topAnchor.constraint(equalTo: progressTimeView.bottomAnchor, constant: 32.0),
            pitchSegmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            pitchSegmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            playSeekStackView.topAnchor.constraint(equalTo: pitchSegmentedControl.bottomAnchor, constant: 32.0),
            playSeekStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            playSeekStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            volumeStackView.topAnchor.constraint(equalTo: playSeekStackView.bottomAnchor, constant: 32.0),
            volumeStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            volumeStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
}
