//
//  SampleViewController.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/07/02.
//
import UIKit
import AVFoundation
import AudioToolbox

class SampleViewController: UIViewController {
    
    //@IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    //Main Audio Engine
    var audioEngine : AVAudioEngine!
    
    //Used to play 1K during recording and Final recording during play
    var audioFile : AVAudioFile!
    
    //Player for playing 1K.mp3
    var audioPlayer : AVAudioPlayerNode!
    
    //Extended Audio File Services to attach to audioFile
    var outref: ExtAudioFileRef?
    
    //Player for playing recorded file
    var audioFilePlayer: AVAudioPlayerNode!
    
    //Mixer to mix 1K with mic input during recording
    var mixer : AVAudioMixerNode!
    
    //Used to define filepath to save recorded file
    var filePath : String? = nil
    
    
    var isPlay = false
    var isRec = false
    
    lazy var playButton: UIButton = {
        var button = UIButton()
        button.setTitle("play", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    //Called On Play Button
    @objc func play(_ sender: Any) {
        if self.isPlay {
            self.playButton.setTitle("PLAY", for: .normal)
            //self.indicator(value: false)
            self.stopPlay()
            self.recButton.isEnabled = true
        } else {
            if self.startPlay() {
                self.recButton.isEnabled = false
                self.playButton.setTitle("STOP", for: .normal)
                //self.indicator(value: true)
            }
        }
    }
    
    lazy var recButton: UIButton = {
        var button = UIButton()
        button.setTitle("rec", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    //Called On Record Button
    @objc func rec(_ sender: Any) {
        if self.isRec {
            self.recButton.setTitle("RECORDING", for: .normal)
            //self.indicator(value: false)
            self.stopRecord()
            self.playButton.isEnabled = true
        } else {
            self.playButton.isEnabled = false
            self.recButton.setTitle("STOP", for: .normal)
            //self.indicator(value: true)
            self.startRecord()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        // MARK: 2 - Setting Up
        
        //Main AudioEngine
        self.audioEngine = AVAudioEngine()
        
        //Used to play 1K.mp3
        self.audioFilePlayer = AVAudioPlayerNode()
        
        //Mixes two inputs
        self.mixer = AVAudioMixerNode()
        
        //Attaches 1K.mp3 input to audio engine
        self.audioEngine.attach(audioFilePlayer)
        
        //Attaches the mixer to the audio engine
        self.audioEngine.attach(mixer)
        
        setLayout()
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        recButton.addTarget(self, action: #selector(rec), for: .touchUpInside)
        //self.indicator(value: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: 1 - Asks user for microphone permission
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio,
                                          completionHandler: { (granted: Bool) in
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setLayout() {
        
        view.backgroundColor = .white
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        recButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playButton)
        view.addSubview(recButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            recButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
            recButton.widthAnchor.constraint(equalToConstant: 80),
            recButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func startRecord() {
        
        self.filePath = nil
        
        //is recording = true
        self.isRec = true
        
        // MARK: 3 - Set up Audio Session
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        // MARK: 4 - Load audio file (Uncomment if you want background sound during recording)
        //self.audioFile = try! AVAudioFile(forReading: Bundle.main.url(forResource: "1K", withExtension: "mp3")!)
        
        // MARK: 5 - Configure Recording format
        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        
        //Connect Microphone to mixer
        self.audioEngine.connect(self.audioEngine.inputNode, to: self.mixer, format: format)
        
        //Connect 1K.mp3 to mixer (Uncomment if you want background sound during recording)
        //self.audioEngine.connect(self.audioFilePlayer, to: self.mixer, format: self.audioFile.processingFormat)
        
        //Connect mixer to mainMixer
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: format)
        
        //Configure 1K.mp3 player settings (Uncomment if you want background sound during recording)
        /* self.audioFilePlayer.scheduleSegment(audioFile,
                                             startingFrame: AVAudioFramePosition(0),
                                             frameCount: AVAudioFrameCount(self.audioFile.length),
                                             at: nil,
                                             completionHandler: self.completion)
        */
        //Set up directory for saving recording
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        self.filePath =  dir.appending("/temp.wav")
        
        //Start Engine
        try! self.audioEngine.start()
        
        //Play 1K.mp3
        //self.audioFilePlayer.play()
    }
    
    func stopRecord() {
        self.isRec = false
        
        //Stop playing 1K file
        self.audioFilePlayer.stop()
        
        //Stop Engine
        self.audioEngine.stop()
        
        //Removes tap on Engine Mixer
        self.mixer.removeTap(onBus: 0)
        
        //Removes reference to audio file
        ExtAudioFileDispose(self.outref!)
        
        //Deactivate audio session
        try! AVAudioSession.sharedInstance().setActive(false)
        
        //Parse the audio input received (wip. NOT USED IN RECORDING OR PLAYING)
        ParseAudioFile()
    }
    
    func startPlay() -> Bool {
        
        if self.filePath == nil {
            return    false
        }
        
        self.isPlay = true
        
        //Sets up Audio Session to play sound
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        //Loads audio file
        self.audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: self.filePath!))
        
        //Connect audio player to the main mixer node of the engine
        self.audioEngine.connect(self.audioFilePlayer, to: self.audioEngine.mainMixerNode, format: audioFile.processingFormat)
        
        //Set up audio player and schedule its playing in the audio stream
        self.audioFilePlayer.scheduleSegment(audioFile,
                                             startingFrame: AVAudioFramePosition(0),
                                             frameCount: AVAudioFrameCount(self.audioFile.length),
                                             at: nil,
                                             completionHandler: self.completion)
        
        //start audio engine
        try! self.audioEngine.start()
        
        //start playing the audio player
        self.audioFilePlayer.play()
        
        return true
    }
    
    //INCOMPLETE (WIP. UNUSED)
    func ParseAudioFile() {
        
        self.audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: self.filePath!))
        
        let totSamples = audioFile.length
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totSamples))!
        try! audioFile.read(into: buffer)
        
        print(buffer.frameLength)
        
        //Get amplitude from buffer frames here
    }
    
    func stopPlay() {
        self.isPlay = false
        
        //Stop the player (if it is playing)
        if self.audioFilePlayer != nil && self.audioFilePlayer.isPlaying {
            self.audioFilePlayer.stop()
        }
        
        //Stop the audio engine
        self.audioEngine.stop()
        
        //Deactivate audio session
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    //Called at the audioplayer.schedule to adjust UI
    func completion() {

        if self.isRec {
            DispatchQueue.main.async {
                self.rec(UIButton())
            }
        } else if self.isPlay {
            DispatchQueue.main.async {
                self.play(UIButton())
            }
        }
    }
    
    // Show/Hide indicator
    /*func indicator(value: Bool) {
        
        DispatchQueue.main.async {
            if value {
                self.indicatorView.startAnimating()
                self.indicatorView.isHidden = false
            } else {
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
            }
        }
    }*/
}
