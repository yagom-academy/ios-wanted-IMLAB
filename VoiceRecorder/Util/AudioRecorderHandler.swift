//
//  AudioRecorderHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

class AudioRecoderHandler {
    
    var audioRecorder = AVAudioRecorder()
    var localFileHandler : LocalFileProtocol
    var updateTimeInterval : UpdateTimer
    var fileName: String?
    var recordTime : String?
    
    enum Recordingstate {
        case recording
        case paused
        case stopped
    }
    
    private var audioEngine : AVAudioEngine!
    private var mixerNode : AVAudioMixerNode!
    private var equalizer : AVAudioUnitEQ!
    private var state : Recordingstate = .stopped
    
    init(handler : LocalFileProtocol, updateTimeInterval : UpdateTimer ){
        self.localFileHandler = handler
        self.updateTimeInterval = updateTimeInterval
        setupSession()
        setupEngine()
    }
    
    
    var recordSettings : [String: Any] = [
        AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 441000.0
    ]
    
    private func setupSession() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true,options: .notifyOthersOnDeactivation)
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
    }
    
    func stopRecording(totalTime: String) {
        mixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        guard let recordFileName = self.fileName else { return }
        let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
        FirebaseStorage.shared.uploadFile(fileUrl: recordFileURL, fileName: recordFileName, totalTime: totalTime)
    }
    
    func setFrequency(frequency : Float) {
        let filter = equalizer.bands[0]
        filter.filterType = .lowPass
        filter.frequency = frequency
        filter.bypass = false
        
        print(filter.frequency)
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
    
    func prepareToRecord() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: .allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
            
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("허용함")
                    } else {
                        //mic disabled!
                    }
                }
            }
            
            enableBuiltInMic()
            let recordFileName = localFileHandler.makeFileName()
            let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
            let audioRecorder = try AVAudioRecorder(url: recordFileURL, settings: recordSettings)
            self.fileName = recordFileName
            self.audioRecorder = audioRecorder
            audioRecorder.isMeteringEnabled = true
            self.audioRecorder.prepareToRecord()
        } catch let error {
            print("Error : setUpRecord - \(error)")
        }
    }
    
    func startRecord() {
        self.prepareToRecord()
        self.audioRecorder.record()
    }
    
    func stopRecord(totalTime : String) {
        self.audioRecorder.stop()
        guard let recordFileName = self.fileName else { return }
        let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
        FirebaseStorage.shared.uploadFile(fileUrl: recordFileURL, fileName: recordFileName, totalTime: totalTime)
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
}
