//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation
import FirebaseStorage

protocol RecordViewControllerDelegate: AnyObject {
    func didFinishRecord()
}

class RecordViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var waveformView: UIView!
    
    @IBOutlet weak var cutOffSlider: UISlider!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playBackwardButton: UIButton!
    @IBOutlet weak var playForwardButton: UIButton!
    
    weak var delegate: RecordViewControllerDelegate?
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var fileName: URL?
    private var recordDate: String?
    private let recorderSetting: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320_000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44_100.0
    ]
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession = AVAudioSession.sharedInstance()
    private var audioPlayer: AVAudioPlayer?
    
    var isRecord = false
    var isPlay = false
    var progressTimer: Timer?
    var counter = 0.0
    var currentPlayTime = 0.0
    
    
    lazy var pencil = UIBezierPath(rect: waveformView.bounds)
    lazy var firstPoint = CGPoint(x: 6, y: waveformView.bounds.midY)
    lazy var jump = (waveformView.bounds.width - (firstPoint.x * 2)) / 200
    let waveLayer = CAShapeLayer()
    var traitLength: CGFloat?
    lazy var start: CGPoint = CGPoint(x: 6, y: waveformView.bounds.midY)
    var width = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
        setupButton(isHidden: true)
        scrollView.updateContentSize()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelRecording()
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        if isRecord {
            progressTimer?.invalidate()
            setupButton(isHidden: false)
            counter = 0.0
            sender.setImage(Icon.circleFill.image, for: .normal)
            audioRecorder?.stop()
            guard let url = audioRecorder?.url,
                  let data = try? Data(contentsOf: url) else { return }
            
            StorageManager().upload(data: data, fileName: recordDate ?? "") { result in
                switch result {
                case .success(_):
                    print("저장 성공🎉")
                    self.delegate?.didFinishRecord()
                case .failure(let error):
                    print("ERROR \(error.localizedDescription)🌡🌡")
                }
            }
        } else {
            sender.setImage(Icon.circle.image, for: .normal)
            setupAudioRecorder()
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            progressTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
        }
        isRecord = !isRecord
    }
    
    @objc func update() {
        counter += 0.01
        recordTimeLabel.text = "\(counter.toString)"
        audioRecorder?.updateMeters()
        writeWaves(audioRecorder!.averagePower(forChannel: 0), true)
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0.0) - 5.0
        counter = audioPlayer?.currentTime ?? 0.0
        currentPlayTime = audioPlayer?.currentTime ?? 0.0
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0.0) + 5.0
        counter = audioPlayer?.currentTime ?? 0.0
        currentPlayTime = audioPlayer?.currentTime ?? 0.0
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            currentPlayTime = audioPlayer?.currentTime ?? 0.0
            progressTimer?.invalidate()
            audioPlayer?.stop()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            playAudio()
            
            progressTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
            setupAudioPlayer()
        }
        isPlay = !isPlay
    }
}

extension RecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlay = false
        currentPlayTime = 0.0
        counter = 0.0
        progressTimer?.invalidate()
        playButton.setImage(Icon.play.image, for: .normal)
    }
}

private extension RecordViewController {
    func setupAudioPlayer() {
        audioPlayer?.delegate = self
    }
    func playAudio() {
        do {
            guard let fileName = fileName else { return }
            audioPlayer = try AVAudioPlayer(contentsOf: fileName)
            audioPlayer?.volume = 1.0
            audioPlayer?.currentTime = currentPlayTime
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            recordTimeLabel.text = "The recording file doesn't exist. Press the record button"
        }
    }
    func setupAudioRecorder() {
        do {
            recordDate = Date.now.dateToString
            fileName = fileURL.appendingPathComponent("\(recordDate ?? "").m4a")
            guard let fileName = fileName else { return }
            audioRecorder = try AVAudioRecorder(url: fileName, settings: recorderSetting)
            audioRecorder?.isMeteringEnabled = true
        } catch {
            print("ERROR \(error.localizedDescription)")
        }
    }
    
    func requestRecord() {
        enableBuiltInMic()
        recordingSession.requestRecordPermission({ allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("allowed record")
                } else {
                    self.openSetting()
                }
            }
        })
    }
    
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setupButton(isHidden: Bool) {
        playButton.isHidden = isHidden
        playBackwardButton.isHidden = isHidden
        playForwardButton.isHidden = isHidden
        if isHidden == false {
            recordButton.isHidden = true
        }
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
    }
    
    
    
    
    func writeWaves(_ input: Float, _ bool: Bool) {
        print(input)
        waveformView.removeConstraints(waveformView.constraints)
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.widthAnchor.constraint(equalToConstant: waveformView.frame.width + width).isActive = true
        waveformView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        waveformView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        waveformView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        if start.x >= view.frame.maxX {
            scrollView.setContentOffset(CGPoint(x: start.x - (view.frame.maxX * 0.8), y: 0.0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }


        if !bool {

            start = firstPoint

            if progressTimer != nil || audioRecorder != nil {
                progressTimer?.invalidate()
                audioRecorder?.stop()
            }

        } else {

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
        }

        pencil.lineWidth = 4.0

        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y + (traitLength ?? 0.0)))

        pencil.move(to: start)
        pencil.addLine(to: CGPoint(x: start.x, y: start.y - (traitLength ?? 0.0)))

        waveLayer.strokeColor = UIColor.red.cgColor

        waveLayer.path = pencil.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor

//        waveLayer.lineWidth = 4.0

        waveformView.layer.addSublayer(waveLayer)
        waveLayer.contentsCenter = waveformView.frame
        waveformView.setNeedsDisplay()

//        if start.x + 10.0 >= waveformView.frame.maxX {
//            waveformView.removeConstraints(waveformView.constraints)
//            waveformView.translatesAutoresizingMaskIntoConstraints = false
//            waveformView.widthAnchor.constraint(equalToConstant: waveformView.frame.width + width).isActive = true
//            waveformView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
//            waveformView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
//            waveformView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
//        }

        start = CGPoint(x: start.x + 10.0, y: start.y)
        
    }
    
    private func enableBuiltInMic() {
        // Get the shared audio session.
        let session = AVAudioSession.sharedInstance()
        // Find the built-in microphone input.
        guard let availableInputs = session.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            print("The device must have a built-in microphone.")
            return
        }
        // Make the built-in microphone input the preferred input.
        do {
            try session.setPreferredInput(builtInMicInput)
        } catch {
            print("Unable to set the built-in mic as the preferred input.")
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
