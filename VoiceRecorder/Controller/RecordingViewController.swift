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
    
    private lazy var pencil = UIBezierPath(rect: waveformView.bounds)
    private var waveLayer = CAShapeLayer()
    private var traitLength : CGFloat?
    private lazy var startPoint : CGPoint = CGPoint(x: 6, y: self.waveformView.bounds.midY)
    
    private var progressTimer: Timer!
    private var recordTimer : Timer!
    private var inRecordMode = true
    private var inPlayMode = false
    private var durationTime = 0.0
    private var currentTime = 0.0
    private var recordCurrentTime = 0.0
    private var totalTime : TimeInterval?
    

    private let audioRecorderHandler = AudioRecoderHandler(localFileHandler: LocalFileHandler(), timeHandler: TimeHandler())
    private let audioPlayerHandler = AudioPlayerHandler(localFileHandler: LocalFileHandler(), timeHandler: TimeHandler())
    
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
    
    @IBAction func recordingButtonTapped(_ sender: UIButton) {
        if inRecordMode {
            
            pencil.removeAllPoints()
            waveLayer.removeFromSuperlayer()
            
            if recordTimer != nil {
                recordTimer.invalidate()
                scrollView.setContentOffset(CGPoint(x: waveformView.frame.minX, y: 0.0), animated:false)
                startPoint = CGPoint(x: 6, y: waveformView.bounds.midY)
            }
            
            currentPlayTimeLabel.text = "00:00"
            endPlayTimeLabel.text = "00:00"
            playProgressBar.progress = 0
            
            sender.controlFlashAnimate(recordingMode: true)
            self.playButton.isEnabled = false
            self.goForwardButton.isEnabled = false
            self.goBackwardButton.isEnabled = false
            do {
                try audioRecorderHandler.startRecording()
            } catch {
                print(error.localizedDescription)
            }
            self.recordTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                      target: self,
                                                      selector: #selector(updateRecordTime),
                                                      userInfo: nil,
                                                      repeats: true)
            RunLoop.main.add(recordTimer, forMode: .common)
            
        } else {
            sender.controlFlashAnimate(recordingMode: false)
            self.playButton.isEnabled = true
            self.goForwardButton.isEnabled = true
            self.goBackwardButton.isEnabled = true
            finishedRecord()
        }
        inRecordMode.toggle()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        inPlayMode.toggle()
        if inPlayMode {
            audioPlayerHandler.play()
        }else {
            audioPlayerHandler.pause()
        }
        if inPlayMode {
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            self.recordingButton.isEnabled = false
        } else {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            self.recordingButton.isEnabled = true
        }
        
    }
    
    @IBAction func setCutoffFreucy(_ sender: UISlider) {
        audioRecorderHandler.setFrequency(frequency: sender.value)
    }
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.seek(to: -5.0)
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.seek(to: 5.0)
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
    }
    
    private func setButton(_ enable: Bool) {
        self.recordingButton.isEnabled = enable
        self.goBackwardButton.isEnabled = enable
        self.goForwardButton.isEnabled = enable
    }
    
    private func finishedRecord() {
        
        guard let fileName = audioRecorderHandler.fileName else { return }
        let recordTotalTime = audioRecorderHandler.updateTimer(totalTime!)
        audioRecorderHandler.stopRecording(totalTime: recordTotalTime)
        audioPlayerHandler.selectPlayFile(fileName,true)
        delegate?.finsihRecord(fileName: fileName, totalTime: recordTotalTime)
        endPlayTimeLabel.text = recordTotalTime
        recordCurrentTime = 0.0
        recordTimer.invalidate()
    }
    
    @objc func updateRecordTime() {
        recordCurrentTime += 0.1
        totalTime = TimeInterval(recordCurrentTime)
        audioRecorderHandler.audioRecod.updateMeters()
        writeWaves(audioRecorderHandler.audioRecod.averagePower(forChannel: 0))

        if let totalTime = totalTime {
            self.totalRecordTimeLabel.text = audioRecorderHandler.updateTimer(totalTime)
        }
    }
    
    @objc func updateProgress() {
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
       
        if !audioPlayerHandler.isPlaying {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            self.recordingButton.isEnabled = true
            self.inPlayMode = false
            progressTimer?.invalidate()
        } else {
            self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    func writeWaves(_ input: Float) {
        
        if startPoint.x >= waveformView.frame.maxX {
            scrollView.setContentOffset(CGPoint(x: startPoint.x - (waveformView.frame.maxX * 0.9), y: 0.0), animated:true)
            
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }
        
        print(input)
        
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
        
        waveLayer.strokeColor = UIColor.orange.cgColor
        
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
