//
//  AudioRecorderHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import Accelerate
import AVFoundation

class AudioRecoderHandler {
    
    
    private var localFileHandler : LocalFileProtocol
    private var timeHandler : TimeProtocol
    private var upLoadFirebase : FirebaseStorageUpload?
    private var mixerNode : AVAudioMixerNode!
    private var audioEngine : AVAudioEngine!
    private var equalizer : AVAudioUnitEQ!
    private var fileName: String?
    
    private var recordFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 1, interleaved: true)
    private let recordFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("input.m4a"))
    
    private var audioRecoder : AVAudioRecorder!
    
    init(localFileHandler : LocalFileProtocol, timeHandler : TimeProtocol ){
        self.localFileHandler = localFileHandler
        self.timeHandler = timeHandler
        upLoadFirebase = FirebaseStorageUpload(UploadRecordfile())
        audioRecoder = AVAudioRecorder()
        setupSession()
        setupEngine()
    }
    
    var Recoder : AVAudioRecorder {
        get {
            return audioRecoder
        }
    }
    
    var saveFileName : String {
        get {
            guard let fileName = fileName else {
                return ""
            }

            return fileName
        }
    }
    
    private func setupSession() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true,options: .notifyOthersOnDeactivation)
            if let recordFormat = recordFormat {
                audioRecoder = try AVAudioRecorder(url: recordFileURL, format: recordFormat)
            }
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        //mic disabled!
                    }
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupEngine() {
        audioEngine = AVAudioEngine()
        
        setEqulizer()
        setMixerNode()
        
        makeConnection()
        audioEngine.prepare()
    }
    private func setMixerNode() {
        mixerNode = AVAudioMixerNode()
        mixerNode.volume = 0
        audioEngine.attach(mixerNode)
    }
    
    private func setEqulizer() {
        equalizer = AVAudioUnitEQ(numberOfBands: 1)
        
        equalizer.bands[0].filterType = .lowPass
        equalizer.bands[0].frequency = 5000
        equalizer.bands[0].bypass = false
        
        audioEngine.attach(equalizer)
    }
    
    private func makeConnection() {
        let inputNode = audioEngine.inputNode
        let inputformat = inputNode.outputFormat(forBus: 0)
        audioEngine.connect(inputNode, to: equalizer, format: inputformat)
        audioEngine.connect(equalizer, to: mixerNode, format: inputformat)
        
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputformat.sampleRate, channels: 1, interleaved: false)
        
        audioEngine.connect(mixerNode, to: audioEngine.mainMixerNode, format: mixerFormat)
    }
    
    func startRecording() throws {
        let tapNode : AVAudioNode = mixerNode
        let format = tapNode.outputFormat(forBus: 0)
        
        let documentURL = localFileHandler.localFileURL
        self.fileName = localFileHandler.makeFileName()
        guard let fileName = fileName else {
            return
        }

        let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent(fileName), settings: format.settings)
        tapNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            try? file.write(from: buffer)
        }
        
        try audioEngine.start()
        
        audioRecoder.record()
        audioRecoder.isMeteringEnabled = true
    }
    
    func stopRecording(totalTime: String) {
        mixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        guard let recordFileName = self.fileName else { return }
        let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
        upLoadFirebase?.uploadFile(fileUrl: recordFileURL, fileName: recordFileName, totalTime: totalTime)
    }
    
    func setFrequency(frequency : Float) {
        let filter = equalizer.bands[0]
        filter.filterType = .lowPass
        filter.frequency = frequency
        filter.bypass = false
        
        print(filter.frequency)
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return timeHandler.convertNSTimeToString(time)
    }
}

