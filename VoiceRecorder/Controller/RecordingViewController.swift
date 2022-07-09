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
    @IBOutlet weak var waveformView: RecordWaveForm!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate : FinishRecord?
    
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
            sender.controlFlashAnimate(recordingMode: true)
           
            
            if recordTimer != nil {
                recordTimer.invalidate()
                scrollView.setContentOffset(CGPoint(x: waveformView.frame.minX, y: 0.0), animated:false)
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
                print("Error - Fail to start Recording \(error)")
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
            setInPlayMode()
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
        }else {
            setNotInPlayMode()
            sender.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    @IBAction func setCutoffFreucy(_ sender: UISlider) {
        audioRecorderHandler.setFrequency(frequency: sender.value)
    }
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.skip(to: -5.0)
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.skip(to: 5.0)
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        playProgressBar.progress = audioPlayerHandler.progress
    }
    
    private func setButton(_ enable: Bool) {
        self.recordingButton.isEnabled = enable
        self.goBackwardButton.isEnabled = enable
        self.goForwardButton.isEnabled = enable
    }
    
    private func finishedRecord() {
        
        let fileName = audioRecorderHandler.saveFileName
        let recordTotalTime = audioRecorderHandler.updateTimer(totalTime!)
        audioRecorderHandler.stopRecording(totalTime: recordTotalTime)
        audioPlayerHandler.selectPlayFile(fileName,true)
        delegate?.finsihRecord(fileName: fileName, totalTime: recordTotalTime)
        endPlayTimeLabel.text = recordTotalTime
        recordCurrentTime = 0.0
        recordTimer.invalidate()
    }

    private func setInPlayMode() {
            audioPlayerHandler.play()
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            self.recordingButton.isEnabled = false
        }

        private func setNotInPlayMode() {
            audioPlayerHandler.pause()
            self.recordingButton.isEnabled = true
        }

    @objc func updateRecordTime() {
        recordCurrentTime += 0.1
        totalTime = TimeInterval(recordCurrentTime)
        audioRecorderHandler.Recoder.updateMeters()
        let averagePower = audioRecorderHandler.Recoder.averagePower(forChannel: 0)
        waveformView.writeWaves(averagePower, scrollview: self.scrollView)

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
