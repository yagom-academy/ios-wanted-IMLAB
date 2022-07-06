//
//  PlaingViewController.swift
//  VoiceRecorder
//
//  Created by Jinhyang Kim on 2022/06/27.
//

import UIKit
import AVFoundation

class PlayingViewController: UIViewController, ObservableObject, AVAudioPlayerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerControlView: UIStackView!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeControlSlider: UISlider!
    @IBOutlet weak var voiceChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var waveImageView: UIImageView!
    @IBOutlet weak var positionProgressView: UIProgressView!
    
    // MARK: - Properties
    
    static let identifier: String = "PlayingViewController"
    
    var isPlayerReady = false {
        willSet {
            objectWillChange.send()
        }
    }
    private var playerTime: PlayerTime = .zero {
        willSet {
            objectWillChange.send()
        }
    }
    
    var fileName : String?
    var fileURL : URL?
    
    private let speedControl = AVAudioUnitVarispeed()
    private let audioEngine = AVAudioEngine()
    private let audioPlayer = AVAudioPlayerNode()
    private let timeEffect = AVAudioUnitTimePitch()
    private var displayLink: CADisplayLink?
    private var timer : Timer?
    
    private var needsFileScheduled = true
    
    private var audioFile: AVAudioFile?
    private var audioLengthSeconds: Double = 0
    private var audioSampleRate: Double = 0
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = audioPlayer.lastRenderTime,
            let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        
        return playerTime.sampleTime
    }
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
        setupDisplayLink()
        titleLabel.text = fileName
        drawWaveForm()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioEngine.stop()
        }
        
    }
    
    // MARK: - Methods
    
    func drawWaveForm() {
        let scale = UIScreen.main.scale;
        let imageSizeInPixel =  CGSize(width:waveImageView.bounds.width * scale,height:waveImageView.bounds.height * scale);
        generateWaveformImage(audioURL: fileURL!, imageSizeInPixel: imageSizeInPixel, waveColor: UIColor.gray) {[weak self] (waveFormImage) in
            if let waveFormImage = waveFormImage {
                self?.waveImageView.image = waveFormImage;
            } else {
                // error
            }
        }
    }
    
    private func setupAudio() {
        guard let fileURL = fileURL else {
            return
        }
        do {
            let file = try AVAudioFile(forReading: fileURL)
            let format = file.processingFormat
            
            audioLengthSamples = file.length
            audioSampleRate = format.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            audioPlayer.volume = volumeControlSlider.value
            
            audioFile = file
            
            configureEngine(with: format)
        } catch {
            print("Error reading the audio file: \(error.localizedDescription)")
        }
        
    }
    
    private func configureEngine(with format: AVAudioFormat) {
        audioEngine.attach(audioPlayer)
        audioEngine.attach(timeEffect)
        
        audioEngine.connect(audioPlayer,
                            to: timeEffect,
                            format: format)
        audioEngine.connect(timeEffect,
                            to: audioEngine.mainMixerNode,
                            format: format)
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            
            scheduleAudioFile()
            isPlayerReady = true
        } catch {
            print("Error starting the player: \(error.localizedDescription)")
        }
        
    }
    
    private func scheduleAudioFile() {
        guard let file = audioFile,
              needsFileScheduled else {
            return
        }
        
        needsFileScheduled = false
        seekFrame = 0
        
        audioPlayer.scheduleFile(file, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    private func playOrPause() {
        if audioPlayer.isPlaying {
            displayLink?.isPaused = true
            audioPlayer.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            displayLink?.isPaused = false

            if needsFileScheduled {
                scheduleAudioFile()
            }
            audioPlayer.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    private func seek(to time: Double) {
        
        guard let audioFile = audioFile else {
            return
        }
        
        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        
        if currentPosition < audioLengthSamples {
            updateTimer()
            needsFileScheduled = false
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            ) {
                self.needsFileScheduled = true
            }
            
            if wasPlaying {
                audioPlayer.play()
            }
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(updateTimer))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    // MARK: - @objc
    
    @objc func updateTimer() {
        
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        if currentPosition >= audioLengthSamples {
            audioPlayer.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            displayLink?.isPaused = true
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        positionProgressView.progress = Float(currentPosition) / Float(audioLengthSamples)
        
        let time = Double(currentPosition) / audioSampleRate
        playerTime = PlayerTime(
            elapsedTime: time,
            remainingTime: audioLengthSeconds - time)
        
    }
    
    // MARK: - IBActions
    
    @IBAction func pressVoiceChangeButton(_ sender: UISegmentedControl) {
        let selectedVoiceValue = sender.selectedSegmentIndex
        
        switch selectedVoiceValue {
        case 0:
            timeEffect.pitch = 0
        case 1:
            timeEffect.pitch = 2400 * 0.5
        case 2:
            timeEffect.pitch = 500 * -0.5
        default:
            timeEffect.pitch = 0
        }
    }
    
    @IBAction func pressPlayButton(_ sender: UIButton) {
        playOrPause()
    }
    
    @IBAction func controlVolumeSlider(_ sender: UISlider) {
        volumeLabel.text = "Volume: \(Int(volumeControlSlider.value))"
        audioPlayer.volume = volumeControlSlider.value
    }
    
    @IBAction func pressPrevButton(_ sender: UIButton) {
        let timeToSeek: Double
        if audioPlayer.isPlaying == true {
            timeToSeek = -5
            seek(to: timeToSeek)
            
        }
    }
    
    @IBAction func pressNextButton(_ sender: UIButton) {
        let timeToSeek: Double
        if audioPlayer.isPlaying == true {
            timeToSeek = 5
            seek(to: timeToSeek)
        }
    }
}
