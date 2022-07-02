//
//  RecordingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import UIKit
import AVFoundation

protocol FinishRecord : AnyObject {
    func finsihRecord(fileName : String, totalTime : String)
}

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var totalRecordTimeLabel: UILabel!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var endPlayTimeLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var waveformView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate : FinishRecord?
    
    lazy var pencil = UIBezierPath(rect: waveformView.bounds)
    var waveLayer = CAShapeLayer()
    var traitLength : CGFloat?
    lazy var startPoint : CGPoint = CGPoint(x: 6, y: self.waveformView.bounds.midY)
    
    var progressTimer: Timer!
    var inRecordMode = true
    var inPlayMode = true

    let audioRecorderHandler = AudioRecoderHandler(handler: LocalFileHandler(), updateTimeInterval: UpdateTimeInterval())
    let audioPlayerHandler = AudioPlayerHandler(handler: LocalFileHandler(), updateTimeInterval: UpdateTimeInterval())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.updateContentSize()
        self.scrollView.isScrollEnabled = false
        self.totalRecordTimeLabel.text = "00:00"
        self.currentPlayTimeLabel.text = "00:00"
        self.endPlayTimeLabel.text = "00:00"
        self.goBackwardButton.isEnabled = false
        self.goForwardButton.isEnabled = false
        self.playButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !inRecordMode {
            finishedRecord()
        }
    }
    
    func setButton(recording: Bool, goBack: Bool, goForward: Bool) {
        self.recordingButton.isEnabled = recording
        self.goBackwardButton.isEnabled = goBack
        self.goForwardButton.isEnabled = goForward
    }
    
    @IBAction func recordingButtonTapped(_ sender: UIButton) {
        if inRecordMode {
            
            pencil.removeAllPoints()
            waveLayer.removeFromSuperlayer()
            
            if progressTimer != nil {
                progressTimer.invalidate()
                scrollView.setContentOffset(CGPoint(x: waveformView.frame.minX, y: 0.0), animated:false)
                startPoint = CGPoint(x: 6, y: waveformView.bounds.midY)
            }
            
            sender.controlFlashAnimate(recordingMode: true)
            self.playButton.isEnabled = false
            audioRecorderHandler.startRecord()
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                      target: self,
                                                      selector: #selector(updateRecordTime),
                                                      userInfo: nil,
                                                      repeats: true)
            RunLoop.main.add(progressTimer, forMode: .common)
            inRecordMode = !inRecordMode
        } else {
            sender.controlFlashAnimate(recordingMode: false)
            self.playButton.isEnabled = true
            finishedRecord()
            inRecordMode = !inRecordMode
        }
    }
    
    func finishedRecord() {
        guard let fileName = audioRecorderHandler.fileName else { return }
        let recordTotalTime = audioRecorderHandler.updateTimer(audioRecorderHandler.audioRecorder.currentTime)
        audioRecorderHandler.stopRecord(totalTime: recordTotalTime)
        delegate?.finsihRecord(fileName: fileName, totalTime: recordTotalTime)
        progressTimer.invalidate()
    }
    
    @objc func updateRecordTime() {
        audioRecorderHandler.audioRecorder.updateMeters()
        self.writeWaves(audioRecorderHandler.audioRecorder.averagePower(forChannel: 0))
        self.totalRecordTimeLabel.text = audioRecorderHandler.updateTimer(audioRecorderHandler.audioRecorder.currentTime)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if inPlayMode {
            audioPlayerHandler.audioPlayer.delegate = self
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            audioPlayerHandler.startPlay(isSelectedFile: false)
            setButton(recording: false, goBack: true, goForward: true)
            endPlayTimeLabel.text = audioPlayerHandler.updateTimer(audioPlayerHandler.audioPlayer.duration)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        } else {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            setButton(recording: true, goBack: false, goForward: false)
            audioPlayerHandler.audioPlayer.pause()
        }
        inPlayMode.toggle()
    }
    
    @objc func updatePlayTime() {
        let player = audioPlayerHandler.audioPlayer
        currentPlayTimeLabel.text = audioPlayerHandler.updateTimer(player.currentTime)
        let time = Float(player.currentTime / (player.duration - 1.0))
        playProgressBar.setProgress(time, animated: true)
    }
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        let player = audioPlayerHandler.audioPlayer
        player.currentTime = player.currentTime - 5.0
        player.play()
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        let player = audioPlayerHandler.audioPlayer
        player.currentTime = player.currentTime + 5.0
        player.play()
    }
    
    func writeWaves(_ input: Float) {
        
        if startPoint.x >= waveformView.frame.maxX {
            scrollView.setContentOffset(CGPoint(x: startPoint.x - (waveformView.frame.maxX * 0.9), y: 0.0), animated:true)
            
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }
        
        if input < -55 {
            traitLength = 0.2
        } else if input < -40 && input > -55 {
            traitLength = (CGFloat(input) + 56) / 3
        } else if input < -20 && input > -40 {
            traitLength = (CGFloat(input) + 41) / 2
        } else if input < -10 && input > -20 {
            traitLength = (CGFloat(input) + 21) * 5
        } else {
            traitLength = (CGFloat(input) + 20) * 4
        }
        
        guard let traitLength = traitLength else {
            return
        }
        
        pencil.lineWidth = 4
        
        pencil.move(to: startPoint)
        pencil.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + traitLength))
        
        pencil.move(to: startPoint)
        pencil.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y - traitLength))
        
        waveLayer.strokeColor = UIColor.red.cgColor
        
        waveLayer.path = pencil.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor
        
        waveLayer.lineWidth = 4
        
        waveformView.layer.addSublayer(waveLayer)
        waveLayer.contentsCenter = waveformView.frame
        waveformView.setNeedsDisplay()
        
        
        startPoint = CGPoint(x: startPoint.x + 5.0, y: startPoint.y)
        
    }
}


extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height+50)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

extension RecordingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
        setButton(recording: true, goBack: false, goForward: false)
    }
}
