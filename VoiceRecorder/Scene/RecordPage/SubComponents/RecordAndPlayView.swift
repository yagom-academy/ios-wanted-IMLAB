//
//  RecordAndPlayView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit
import AVFoundation

class RecordAndPlayView: UIView {
    private let networkManager = RecordNetworkManager()
    private let recordManager = RecordManager()

    var recorder: AVAudioRecorder?
    var audioFile: URL!
    var timer: Timer?
    
    var barWidth: CGFloat = 2.0
    
    var color = UIColor.red.cgColor
    var waveForms = [Int](repeating: 0, count: 200)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        var bar: CGFloat = 0
        
        context.clear(rect)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
        context.fill(rect)
        context.setLineWidth(1.5)
        context.setStrokeColor(self.color)
        
        let centerY: CGFloat = 150
        
        for i in 0..<self.waveForms.count {
            let firstX = bar * self.barWidth
            let firstY = centerY + CGFloat(self.waveForms[i])
            let secondY = centerY - CGFloat(self.waveForms[i])
            
            context.move(to: CGPoint(x: firstX, y: centerY))
            context.addLine(to: CGPoint(x: firstX, y: firstY))
            context.move(to: CGPoint(x: firstX, y: centerY))
            context.addLine(to: CGPoint(x: firstX, y: secondY))
            context.strokePath()
            
            bar += 1
        }
    }
    
    private let frequencyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var viewModel: PlayerButtonViewModel!
    
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
            
            button.addTarget(self, action: #selector(didTapBackwardButton(sender:)), for: .touchUpInside)
            
            return button
        }()
        
        let playButton: UIButton = {
            let button = UIButton()
            button.setImage(systemName: "play.fill", state: .normal)
            button.setImage(systemName: "pause.fill", state: .selected)
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
            
            button.addTarget(self, action: #selector(didTapForwardButton(sender:)), for: .touchUpInside)
            
            return button
        }()
        
        [backwardButton, playButton, forwardButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    @objc func didTapBackwardButton(sender: UIButton) {
        viewModel.goBackward()
    }
    
    @objc func didTapForwardButton(sender: UIButton) {
        viewModel.goForward()
    }
    
    @objc func didTapPlayButton(sender: UIButton) {
<<<<<<< HEAD
        sender.isSelected = viewModel.playPauseAudio()
=======
        sender.isSelected = !sender.isSelected
>>>>>>> feature-record
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
            startRecord()
        } else {
<<<<<<< HEAD
            recordManager.endRecord()
            
            guard let audioFile = recordManager.makePlayer() else {
                return
            }
            viewModel.setAudioFile(audioFile)
=======
            endRecord()
>>>>>>> feature-record
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
        let file = recordManager.dateToFileName(Date()) + "+" + viewModel.duration()
        // 저장 후 dismiss
        networkManager.saveRecord(filename: file)
    }
}

extension RecordAndPlayView {
    
    func bind(_ viewModel: PlayerButtonViewModel) {
        self.viewModel = viewModel

    }
    
    private func layout() {
        [
            frequencyView,
            buttonStackView,
            recordButton,
            downloadButton
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        frequencyView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        frequencyView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        frequencyView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        frequencyView.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
        
        buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        buttonStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        recordButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        
        downloadButton.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
    }
}

extension RecordAndPlayView {
    func startRecord() {
        var currentSample = 0
        let numberOfSamples = 200

        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0]

        audioFile = docsDir.appendingPathComponent("record.m4a")

        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
            recorder?.record()

            recorder?.isMeteringEnabled = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                self.recorder?.updateMeters()
                self.waveForms[currentSample] = self.recordManager.normalizeSoundLevel(self.recorder?.averagePower(forChannel: 0))
                currentSample = (currentSample + 1) % numberOfSamples
                DispatchQueue.main.async {
                    self.setNeedsDisplay()
                }
            })
        } catch {
            print("Record Error: \(error.localizedDescription)")
        }
    }
    
    func endRecord() {
//        var fileName = dateToFileName(Date())
        timer?.invalidate()
        
        recorder?.stop()
        recorder = nil
    }
}
