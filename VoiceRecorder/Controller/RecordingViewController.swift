//
//  RecordingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var waveformView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var pencil = UIBezierPath(rect: waveformView.bounds)
    var waveLayer = CAShapeLayer()
    var traitLength : CGFloat?
    lazy var startPoint : CGPoint = CGPoint(x: 6, y: self.waveformView.bounds.midY)
    
    var progressTimer: Timer!
    var inRecordMode = true
    var inPlayMode = true
    
    let audioRecorderHandler = AudioRecoderHandler(handler: LocalFileHandler(), updateTimeInterval: UpdateTimeInterval())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.updateContentSize()
        self.scrollView.isScrollEnabled = false
        self.recordTimeLabel.text = "00:00"
        self.goBackwardButton.isEnabled = false
        self.goForwardButton.isEnabled = false
        self.playButton.isEnabled = false
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
            waveformView.frame.size.width = 300
            
            if progressTimer != nil {
                progressTimer.invalidate()
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
            print(waveformView.frame.size.width)
            print(waveformView.frame.size.width)
            audioRecorderHandler.stopRecord(totalTime: audioRecorderHandler.audioRecorder.currentTime)
            progressTimer.invalidate()
            inRecordMode = !inRecordMode
        }
    }
    
    @objc func updateRecordTime() {
        audioRecorderHandler.audioRecorder.updateMeters()
        self.writeWaves(audioRecorderHandler.audioRecorder.averagePower(forChannel: 0))
        self.recordTimeLabel.text = audioRecorderHandler.updateTimer(audioRecorderHandler.audioRecorder.currentTime)
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
