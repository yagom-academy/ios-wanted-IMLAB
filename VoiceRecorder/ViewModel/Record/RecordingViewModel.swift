//
//  RecordingViewModel.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/07.
//

import Foundation
import AVFAudio
import AVFoundation

class RecordingViewModel {
    let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var EQNode = AVAudioUnitEQ(numberOfBands: 2)
    private var audioPlayerNode = AVAudioPlayerNode()
    var setting: [String:Any]?
    var audioPlayer: AVAudioPlayer?
    let recordFileURL: URL?
    let settings = [AVFormatIDKey: kAudioFileMPEG4Type, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1] as [String : Any]
    
    @Published var isRecording = false
    @Published var isPlaying = false
    
    init() {
        print("init Recording View Model")
        setupAudioSession()
        
        prepareEngine()
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            try session.setActive(true)
            
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func prepareEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        //inputNode voice Processing enable
        prepareInputNode()
        
        prepareFilter(format)
        
        nodeAttachs()
        
        connectEngineNodes(from: inputNode, format: format)
        
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in

            if self.audioFile == nil {
                if let file = try? AVAudioFile(forWriting: self.recordFileURL, settings: format.settings, commonFormat: .pcmFormatFloat32, interleaved:false) {
                    self.audioFile = file
                }
            }

            
            if let audioFile = self.audioFile {
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Prepare Engine's Node
    func prepareInputNode() {
        do {
            try audioEngine.inputNode.setVoiceProcessingEnabled(true)
        } catch {
            print("Error in prepare input node \(error)")
        }
    }
    
    func prepareFilter(_ format:AVAudioFormat) {
        let firstParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        firstParams.filterType = .resonantHighPass
        firstParams.frequency = Float(format.sampleRate / 2)
        firstParams.bypass = false
        
        let secondParams = EQNode.bands[1] as AVAudioUnitEQFilterParameters
        secondParams.filterType = .resonantLowPass
        secondParams.frequency = 50
        secondParams.bypass = false
    }
    
    func nodeAttachs() {
        audioEngine.attach(EQNode)
        audioEngine.attach(audioPlayerNode)
    }
    
    func connectEngineNodes(from inputNode: AVAudioInputNode, format: AVAudioFormat) {
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        
        audioEngine.connect(inputNode, to: EQNode, format: format)
        audioEngine.connect(EQNode, to: mainMixer, format: format)
        audioEngine.connect(audioPlayerNode, to: outputNode, format: format)
    }
    
    func checkEngineIsRunning() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("engine not start")
            }
        }
    }
    
    //MARK: - Method of Recording
    func startRec() {
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("could not config engine")
        }
        self.isRecording = true
        print("Start rec")
    }
    
    func stopRec() {
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print(error.localizedDescription)
            return
        }
        print("stop rec")
        self.isRecording = false
    }
    
    //MARK: - Method of cut off frequency
    func changeFrequency(value: Float) {
        let paramter = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        print(value)
        paramter.frequency = value
    }
    
    //MARK: - Method of PlayerNode
    func play() {
        checkEngineIsRunning()
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error in \(error.localizedDescription)")
        }
        
        if let audioFile = audioFile {
            audioPlayerNode.volume = 0.5
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isPlaying = false
                    self?.stopPlay()
                }
            }

            audioPlayerNode.play()
            
            self.isPlaying = true
        }
    }
    
    func pausePlay() {
        audioPlayerNode.pause()
        self.isPlaying = false
    }
    
    func stopPlay() {
        audioPlayerNode.stop()
    }
    
    private func createURL() {
        
    }
}
