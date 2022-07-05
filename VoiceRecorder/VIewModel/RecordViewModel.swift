//
//  RecordViewModel.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/02.
//

import Foundation
import AVFAudio
import QuartzCore
import Combine

protocol RecordDrawable: AnyObject{
    func updateValue(_ value:CGFloat)
}

enum RecorderError:Error{
    case permissionError
    case initError
}

class RecordViewModel{
    // 오디오 및 마이크 권환 관련 Properties
    var audioPermission: Bool = false
    
    // 엔진 설정 Properties
    var player = AVAudioPlayerNode()
    var recordFile: AVAudioFile?
    var engine = AVAudioEngine()
    var recordFormat: AVAudioFormat!
    private var audioSampleRate: Double = 0
    
    // 녹음시 녹음 파일 생성 Properties
    var fileURL = URL(fileURLWithPath: "input.caf", isDirectory: false, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
    
    // 녹음 파일 재생 Properties
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    var audioLengthSeconds: Double = 0
    private var currentFrame: AVAudioFramePosition {
        guard let lastRanderTime = player.lastRenderTime,
              let playerTime = player.playerTime(forNodeTime: lastRanderTime) else {
            return 0
        }
        
        return playerTime.sampleTime
    }
    
    // 뷰 관련 Properties
    private var displayLink:CADisplayLink?
    @Published var progressValue: Float = 0
    @Published var isPlaying: Bool = false
    @Published var isRecording: Bool = false

    // 파이어 관련 Properties
    let firebaseManger = FirebaseStorageManager.shared
    
    weak var delegate:RecordDrawable?

    init() throws {
        checkPermission()
        
        if audioPermission{
            self.recordFile = try AVAudioFile(forReading: fileURL)
            guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 1, interleaved: true) else {
                throw RecorderError.initError
            }
            self.recordFormat = format
            
            
            self.setupEngine()
            self.setUpDisplayLink()
        }else{
            throw RecorderError.permissionError
        }
    }
    
    func checkPermission(){
        switch AVAudioSession.sharedInstance().recordPermission{
        case .granted:
            audioPermission = true
        case .denied:
            audioPermission = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                self.audioPermission = allowed
            }
        @unknown default:
            fatalError(RecorderError.permissionError.localizedDescription)
        }
    }
    
    func setupEngine(){
        engine.attach(player)
        
        let input = engine.inputNode
        let output = engine.outputNode
        let mainMixer = engine.mainMixerNode
        let EQNode = AVAudioUnitEQ(numberOfBands: 1)
        
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        
        filterParams.filterType = .highPass
        filterParams.frequency = 100.0
        filterParams.bypass = true
        filterParams.filterType = .lowPass
        filterParams.frequency = 10
        engine.attach(EQNode)
        
        do{
            try input.setVoiceProcessingEnabled(true)
        } catch {
            print("Could not enable voice Processing --- \(error.localizedDescription)")
        }
        engine.connect(player, to: EQNode, format: recordFormat)
        engine.connect(EQNode, to: mainMixer, format: recordFormat)
        
        input.installTap(onBus: 0, bufferSize: 1024, format: recordFormat) { [weak self] buffer, when in
            guard let self = self else { return }
            if self.isRecording{
                do{
                    try self.recordFile?.write(from: buffer)
                    self.delegate?.updateValue(CGFloat(self.calculateBuffer(buffer: buffer)))
                    
                } catch {
                    print("Could not write buffer --- \(error)")
                }
            }
        }
        
        mainMixer.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, when in
//            print(self.calculateBuffer(buffer: buffer))
        }
        
        engine.prepare()
        engineStart()
    }
    
    func engineStart(){
        do{
            try engine.start()
        } catch {
            print("Could not start engine --- \(error)")
        }
    }
    
    func checkEngineRunning(){
        if !engine.isRunning{
            engineStart()
        }
    }
    
    func startRecord(){
        player.stop()
        
        do{
            recordFile = try AVAudioFile(forWriting: fileURL, settings: recordFormat.settings)
            isRecording = true
        } catch {
            print("Could not create file for recording --- \(error)")
        }
    }
    
    func stopRecording(){
        if engine.isRunning{
            isRecording = false
            recordFile = nil
        }
        
//        firebaseManger.uploadData(url: fileURL, fileName: Date().toString("yyyy_MM_dd_HH_mm_ss") + ".m4a")
    }
    
    func startPlaying(){
        do {
           recordFile = try AVAudioFile(forReading: fileURL)
            
            if let file = recordFile{
                audioLengthSamples = file.length
                audioSampleRate = file.processingFormat.sampleRate
                audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
                
                player.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { type in
                    if type == .dataPlayedBack{
                        self.isPlaying = false
                    }
                }
                
                print("schedule file start")
            }
        } catch {
            print("Error reading the audio file --- \(error)")
        }
        player.play()
        isPlaying = true
        displayLink?.isPaused = false
    }
    
    func stopPlaying(){
        if player.isPlaying{
            player.pause()
            isPlaying = false
            displayLink?.isPaused = true
        }
    }
    
    func skip(forwards:Bool){
        let timeToSeek:Double = forwards ? 5:-5
        seek(to: timeToSeek)
    }
    
    func seek(to time:Double){
        guard let recordFile = recordFile else {
            return
        }

        let offset = AVAudioFramePosition(time * audioSampleRate)
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        
        currentPosition = seekFrame
        
        let wasPlaying = player.isPlaying
        
        player.stop()
        isPlaying = false
        
        if currentPosition < audioLengthSamples {
            updateDisplay()
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            player.scheduleSegment(recordFile, startingFrame: seekFrame, frameCount: frameCount, at: nil)
            
            if wasPlaying{
                self.isPlaying = true
                player.play()
            }
        }
    }
    
    func setUpDisplayLink(){
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    @objc func updateDisplay(){
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentFrame, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition >= audioLengthSamples {
            player.stop()
            
            seekFrame = 0
            currentPosition = 0
            isPlaying = false
        }
        
        let time = Float(currentPosition) / Float(audioLengthSamples)
        progressValue = time
    }
    
    func calculateBuffer(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else {
            return 0.0
        }
        
        let channelDataValue = channelData.pointee
        
        let valueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{
            channelDataValue[$0]
        }
        
        let rms = sqrt(valueArray.map{
            return $0 * $0
        }.reduce(0, +) / Float(buffer.frameLength))
        
        let avgPower = 20 * log10(rms)
        
        let meterLevel = self.scaledPower(power: avgPower)
        return meterLevel
    }
    
    func scaledPower(power:Float) -> Float {
        guard power.isFinite else {
            return 0.0
        }
        
        let minDb: Float = -80
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }
}
