//
//  RecordAndPlayView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class RecordAndPlayView: UIView {
    private let recordManager = RecordManager()
    private let networkManager = RecordNetworkManager()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 40
        stackView.isHidden = true
        
        let backwardButton: UIButton = {
            let button = UIButton()
            button.setImage(systemName: "gobackward.5", state: .normal)
            button.tintColor = .label
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return button
        }()
        
        let playButton: UIButton = {
            let button = UIButton()
            button.setImage(systemName: "play", state: .normal)
            button.setImage(systemName: "pause", state: .selected)
            button.tintColor = .label
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.addTarget(self, action: #selector(didTapPlayButton(sender:)), for: .touchUpInside)
            
            return button
        }()
        
        let forwardButton: UIButton = {
            let button = UIButton()
            button.setImage(systemName: "goforward.5", state: .normal)
            button.tintColor = .label
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return button
        }()
        
        [backwardButton, playButton, forwardButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    @objc func didTapPlayButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if recordManager.isPlaying() {
            recordManager.pausePlay()
        } else {
            recordManager.startPlay()
        }
    }
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "circle.fill", state: .normal)
        button.setImage(systemName: "square.fill", state: .selected)
        button.tintColor = .red
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        button.addTarget(self, action: #selector(didTapRecordButton(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func didTapRecordButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            recordManager.startRecord()
        } else {
            recordManager.endRecord()
            recordManager.makePlayer()
            buttonStackView.isHidden = false
        }
    }
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "arrow.down.circle", state: .normal)

        button.tintColor = .label
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        button.addTarget(self, action: #selector(didTapDownloadButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc func didTapDownloadButton() {
        let file = recordManager.dateToFileName(Date())
        // 저장 후 dismiss
        networkManager.saveRecord(filename: file)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecordAndPlayView {
    private func layout() {
        [
            buttonStackView,
            recordButton,
            downloadButton
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        buttonStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        recordButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        
        downloadButton.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
    }
}
