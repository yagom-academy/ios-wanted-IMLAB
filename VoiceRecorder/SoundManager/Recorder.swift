//
//  Recorder.swift
//  VoiceRecorder
//
//  Created by 백유정 on 2022/06/30.
//

import Foundation
import AVFoundation

protocol Recording {
    func resumeRecording() throws
    func pauseRecording()
    func stopRecording()
}

class Recorder {
    enum RecordingState {
        case record
        case pause
        case stop
    }
    
    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    private var playerNode: AVAudioPlayerNode!
    private var audioFile: AVAudioFile!
    //private var EQNode: AVAudioUnitEQ!
    private var state: RecordingState = .stop
    
    var filePath : String? = nil
    var outref: ExtAudioFileRef?
    
    init() {
        setupSession()
        setupEngine()
    }
}

extension Recorder {
    
    /// 오디오세션 셋업
    func setupSession() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("[ERROR]")
        }
    }
    
    /// 오디오 엔진 셋업
    func setupEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        mixerNode.volume = 0 // 레코딩 준비를 위해 볼륨을 0으로 변경
        engine.attach(mixerNode)
        
        makeConnection()
        
        engine.prepare()
    }
    
    /// 노드를 엔진에 연결
    fileprivate func makeConnection() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        engine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        
        engine.connect(mixerNode, to: engine.mainMixerNode, format: mixerFormat)
    }
    
    
    func setupFrequency() {
        //EQNode = AVAudioUnitEQ.init()
        
        //let filerParams: AVAudioUnitEQFilterParameters!
        //filerParams = AVAudioUnitEQFilterParameters()
        
        //filerParams.frequency
    }
    
    /// 녹음을 실행
    @objc func recording() throws {
        let tapNode: AVAudioNode = mixerNode
        let format = tapNode.outputFormat(forBus: 0)
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent("recording.caf"), settings: format.settings)
        
        tapNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            try? file.write(from: buffer)
        }
        
        // 엔진을 실행
        try engine.start()
        
        state = .record
    }
    
    func startRecord() {
        self.filePath = nil
        
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32,
                                    sampleRate: 44100.0,
                                    channels: 1,
                                    interleaved: true)
            
        //Connect Microphone to mixer
        engine.connect(engine.inputNode, to: mixerNode, format: format)
        
        //Connect mixer to mainMixer
        engine.connect(mixerNode, to: self.engine.mainMixerNode, format: format)
        
        //Set up directory for saving recording
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        self.filePath =  dir.appending("/temp.wav")
            
        //Create file to save recording
        _ = ExtAudioFileCreateWithURL(URL(fileURLWithPath: self.filePath!) as CFURL,
                                          kAudioFileWAVEType,
                                          (format?.streamDescription)!,
                                          nil,
                                          AudioFileFlags.eraseFile.rawValue,
                                          &outref)
            
        //Tap on the mixer output (MIXER HAS BOTH MICROPHONE AND 1K.mp3)
        mixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount((format?.sampleRate)! * 0.4), format: format, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                
            //Audio Recording Buffer
            let audioBuffer : AVAudioBuffer = buffer
                
            //Write Buffer to File
            _ = ExtAudioFileWrite(self.outref!, buffer.frameLength, audioBuffer.audioBufferList)
        })
            
        //Start Engine
        try! engine.start()
    }
        
    func stopRecord() {
        //Stop playing 1K file
        playerNode.stop()
        
        //Stop Engine
        engine.stop()
            
        //Removes tap on Engine Mixer
        mixerNode.removeTap(onBus: 0)
            
        //Removes reference to audio file
        ExtAudioFileDispose(self.outref!)
            
        //Deactivate audio session
        try! AVAudioSession.sharedInstance().setActive(false)
            
        //Parse the audio input received (wip. NOT USED IN RECORDING OR PLAYING)
        ParseAudioFile()
    }
    
    func ParseAudioFile() {
        audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: self.filePath!))
            
        let totSamples = audioFile.length
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totSamples))!
        try! audioFile.read(into: buffer)
            
        print(buffer.frameLength)
    }
    

    @objc func startPlay() -> Bool {
        if filePath == nil {
            return false
        }
        
        //Sets up Audio Session to play sound
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        //Loads audio file
        audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: self.filePath!))
        
        //Connect audio player to the main mixer node of the engine
        engine.connect(self.playerNode, to: self.engine.mainMixerNode, format: audioFile.processingFormat)
        
        //Set up audio player and schedule its playing in the audio stream
        playerNode.scheduleSegment(audioFile,
                                   startingFrame: AVAudioFramePosition(0),
                                    frameCount: AVAudioFrameCount(self.audioFile.length),
                                    at: nil)
        
        //start audio engine
        try! engine.start()
        
        //start playing the audio player
        playerNode.play()
        
        return true
    }
    /// 재생
    @objc func playing() throws {
        if let engine = engine {
            if !engine.isRunning {
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let file = try! AVAudioFile(forReading: documentURL)
                let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                
                try! file.read(into: buffer!)
                
                // 엔진을 실행
                try engine.start()
                
                playerNode.play()
            }
        }
    }
}

extension Recorder: Recording {
    
    func resumeRecording() throws {
        try engine.start()
        state = .record
    }
    
    func pauseRecording() {
        engine.pause()
        state = .pause
    }
    
    func stopRecording() {
        mixerNode.removeTap(onBus: 0)
        engine.stop()
        state = .stop
    }
}
