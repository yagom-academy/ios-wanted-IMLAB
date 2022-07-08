//
//  AudioPlotView.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/08.
//

import UIKit
import AVFAudio
import Accelerate

class AudioVisualizeView: UIScrollView {
    
    private var audioPlotView: AudioPlotView = {
        var audioPlotView = AudioPlotView()
        audioPlotView.translatesAutoresizingMaskIntoConstraints = false
        return audioPlotView
    }()
    
    init() {
        super.init(frame: .zero)
        self.indicatorStyle = .white
        self.backgroundColor = .black
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
        setAudioPlotView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.indicatorStyle = .white
        self.backgroundColor = .black
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
        setAudioPlotView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAudioPlotView()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAudioPlotView() {
        self.addSubview(audioPlotView)
        NSLayoutConstraint.activate([
            
            audioPlotView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            audioPlotView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            audioPlotView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            audioPlotView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            audioPlotView.heightAnchor.constraint(equalTo: self.heightAnchor)
        
        ])
    }
    
    private func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val : Float = 0
        vDSP_measqv(data, 1, &val, frameLength)
        val *= 1000
        return val
    }
    
    func processAudioData(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else {return}
        let frames = buffer.frameLength
        
        let rmsValue = rms(data: channelData, frameLength: UInt(frames))
        audioPlotView.waveforms.append(Int(rmsValue))
        DispatchQueue.main.async { [self] in
            self.audioPlotView.setNeedsDisplay()
        }
    }
    func udpateVisualizerContentSize() {
        self.contentSize.width += 5
    }
    func getWaveformData() -> [Int] {
        return audioPlotView.waveforms
    }
    
}
