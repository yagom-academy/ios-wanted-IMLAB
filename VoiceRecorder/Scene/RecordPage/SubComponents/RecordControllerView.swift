//
//  RecordAndPlayView.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import AVFoundation
import UIKit

class RecordControllerView: UIView {
    private let networkManager =  RecordNetworkManager.shared
    private let recordManager: RecordService!
    var delegate: RecordControllerDelegate?

    var recorder: AVAudioRecorder?
    var audioFile: URL!
    var timer: Timer?

    var barWidth: CGFloat = 2.0

    var color = UIColor.red.cgColor
    var waveForms = [Int](repeating: 0, count: 200)
    var viewModel: RecordControllerViewModel!
    
    init(_ recordManager: RecordService) {
        self.recordManager = recordManager
        
        super.init(frame: .zero)

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
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(rect)
        context.setLineWidth(1.5)
        context.setStrokeColor(color)

        let centerY: CGFloat = 150

        for i in 0 ..< waveForms.count {
            let firstX = bar * barWidth
            let firstY = centerY + CGFloat(waveForms[i])
            let secondY = centerY - CGFloat(waveForms[i])

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
            endRecord()
            delegate?.endRecord()
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

extension RecordControllerView {
    func bind(_ viewModel: RecordControllerViewModel) {
        self.viewModel = viewModel
    }

    private func layout() {
        [
            frequencyView,
            recordButton,
            downloadButton,
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        frequencyView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        frequencyView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        frequencyView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        frequencyView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true

        recordButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true

        downloadButton.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
    }
}

extension RecordControllerView {
    func startRecord() {
        var currentSample = 0
        let numberOfSamples = waveForms.count

        audioFile = Config.getRecordFilePath()

        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
            recorder?.record()

            recorder?.isMeteringEnabled = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] _ in
                guard let self = self else { return }
                self.recorder?.updateMeters()

                if currentSample == numberOfSamples {
                    self.waveForms.removeFirst()
                    self.waveForms.append(self.recordManager.normalizeSoundLevel(self.recorder?.averagePower(forChannel: 0)))
                } else {
                    self.waveForms[currentSample] = self.recordManager.normalizeSoundLevel(self.recorder?.averagePower(forChannel: 0))
                }

                if currentSample < numberOfSamples {
                    currentSample += 1
                }

                DispatchQueue.main.async {
                    self.setNeedsDisplay()
                }
            })
        } catch {
            print("Record Error: \(error.localizedDescription)")
        }
    }

    func endRecord() {
        timer?.invalidate()

        recorder?.stop()
        recorder = nil
        
        guard let audioFile = audioFile else {
            return
        }

        do {
            let newAudioFile = try AVAudioFile(forReading: audioFile)
            viewModel.setAudioFile(newAudioFile)
        } catch let error {
            print("play record file error: \(error)")
        }
    }
}
