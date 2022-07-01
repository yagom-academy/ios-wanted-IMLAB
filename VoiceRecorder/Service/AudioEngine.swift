//
//  AudioEngine.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/28.
//

import Foundation
import AVFAudio
import Accelerate

class AudioEngine{
    
    private var recordedFileURL = URL(fileURLWithPath: "input.caf", isDirectory: false, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
    private var recordedFilePlayer = AVAudioPlayerNode()
    private var recordedFile: AVAudioFile?
    private var engine = AVAudioEngine()
    public private(set) var isRecording = false
    private var isNewRecordingAvailable = false
    public private(set) var voiceIOFormat:AVAudioFormat
    
    //Audio Second Change Properties
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var audioSampleRate:Double = 0
    private var audioLengthSeconds: Double = 0
    private var currentFrame:AVAudioFramePosition{
        guard let lastRenderTime = recordedFilePlayer.lastRenderTime,
              let playerTime = recordedFilePlayer.playerTime(forNodeTime: lastRenderTime) else{
            return 0
        }
        
        return playerTime.sampleTime
    }

    //Audio Engine init Error
    enum AudioEngingError:Error{
        case bufferError
        case formatError
    }
    
    init() throws{
        engine.attach(recordedFilePlayer)
        print("Record file URL: \(recordedFileURL.absoluteString)")
        guard let voiceIOFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: true) else{
            throw AudioEngingError.formatError
        }
        self.voiceIOFormat = voiceIOFormat

    }
    
    //Audio Engine SetUp
    func setup(){
        let input = engine.inputNode
        do{
            try input.setVoiceProcessingEnabled(true)
        } catch {
            print("Could not enable voice Processing \(error)")
            return
        }

        let output = engine.outputNode
        let mainMixer = engine.mainMixerNode
        
        engine.connect(recordedFilePlayer, to: mainMixer, format: voiceIOFormat)
        engine.connect(mainMixer, to: output, format: voiceIOFormat)
        
        input.installTap(onBus: 0, bufferSize: 256, format: voiceIOFormat) { buffer, when in
            if self.isRecording{
                do{
                    try self.recordedFile?.write(from: buffer)
                } catch {
                    print("could not write buffer : \(error)")
                }
            }
        }
        
        mainMixer.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, when in }
    }
    
    private static func getBuffer(fileURL:URL)->AVAudioPCMBuffer?{
        let file:AVAudioFile!
        do{
            try file = AVAudioFile(forReading: fileURL)
        } catch {
            print("Could not load file \(error)")
            return nil
        }
        
        file.framePosition = 0
        
        let bufferCapacity = AVAudioFrameCount(file.length) + AVAudioFrameCount(file.processingFormat.sampleRate * 0.1)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: bufferCapacity) else{return nil}
        
        do{
            try file.read(into: buffer)
        } catch {
            print("Could not load file into buffer \(error)")
            return nil
        }
        
        file.framePosition = 0
        return buffer
    }
    
    //Engine Start
    func start(){
        do{
            try engine.start()
        } catch {
            print("Could not start engine: \(error)")
        }
    }
    
    //if Engine was not running, Start Engine
    func checkEngineRunning(){
        if !engine.isRunning{
            start()
        }
    }
    
    //Recording Toggle
    func toggleRecording(){
        if isRecording{
            isRecording = false
            recordedFile = nil
        }else{
            recordedFilePlayer.stop()
            
            do{
                recordedFile = try AVAudioFile(forWriting: recordedFileURL,settings: voiceIOFormat.settings)
                isNewRecordingAvailable = true
                isRecording = true
            } catch {
                print("Could not create file for recording \(error)")
            }
        }
    }
    
    var isPlaying: Bool {
        return recordedFilePlayer.isPlaying
    }
    
    //Playing Toggle
    func togglePlaying(completion:@escaping()->Void){
        if recordedFilePlayer.isPlaying{
            recordedFilePlayer.pause()
        }else{
            do{
                recordedFile = try AVAudioFile(forReading: recordedFileURL)
                if let recordedFile = recordedFile {
                    audioLengthSamples = recordedFile.length
                    audioSampleRate = recordedFile.processingFormat.sampleRate
                    audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
                }
            } catch {
                print("Error reading the audio file \(error.localizedDescription)")
            }
            
            guard let recordedBuffer = AudioEngine.getBuffer(fileURL: recordedFileURL) else{return}
            
            recordedFilePlayer.scheduleBuffer(recordedBuffer,at: nil)
            
            recordedFilePlayer.play()
            
        }
    }
    
    //Skip
    func skip(forwards:Bool){
        let timeToSeek:Double
        
        if forwards{
            timeToSeek = 5
        } else {
            timeToSeek = -5
        }
        
        seek(to: timeToSeek)
    }
    
    //현재 위치 + 시간 위치로 이동후 실행 메소드
    func seek(to time:Double){
        guard let recordedFile = recordedFile else {
            return
        }

        let offset = AVAudioFramePosition(time * audioSampleRate)
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = recordedFilePlayer.isPlaying
        recordedFilePlayer.stop()
        
        if currentPosition < audioLengthSamples{
            updateDisplay()
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            recordedFilePlayer.scheduleSegment(recordedFile, startingFrame: seekFrame, frameCount: frameCount, at: nil)
            
            if wasPlaying{
                recordedFilePlayer.play()
            }
        }
    }
    
    // 현재 시간 + 5초 계산 메소드
    func updateDisplay(){
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition >= audioLengthSamples{
            recordedFilePlayer.stop()
            
            seekFrame = 0
            currentPosition = 0
        }
        let time = Double(currentPosition) / audioSampleRate
        print("All second \(audioLengthSeconds)")
        print("Remain time \(audioLengthSeconds - time)")
    }
}

//MARK: - 외부함수
extension AudioEngine{
    
    func firebaseUpload(){
        FirebaseStorageManager.shared.uploadData(url: self.recordedFileURL, fileName: Date().convertString()+".m4a")
    }
    
    //buffer를 float으로 변환하는 함수
    //float으로 변환하여 파형으로 전달?
//    func convertData(buffer:AVAudioPCMBuffer){
//        let channelCount = Int(buffer.format.channelCount)
//        let length = vDSP_Length(buffer.frameLength)
//        if let floatData = buffer.floatChannelData{
//            for channel in 0..<channelCount{
////                print(calculatePowers(data: floatData[channel], strideFrames: buffer.stride, length: length))
//            }
//        } else if let int16Data = buffer.int16ChannelData{
//            for channel in 0..<channelCount{
//                var floatChannelData:[Float] = Array(repeating: Float(0.0), count: Int(buffer.frameLength))
//                vDSP_vflt16(int16Data[channel], buffer.stride, &floatChannelData, buffer.stride, length)
//                var scalar = Float(INT16_MAX)
//                vDSP_vsdiv(floatChannelData, buffer.stride, &scalar, &floatChannelData, buffer.stride, length)
//
//                calculatePowers(data: floatChannelData, strideFrames: buffer.stride, length: length)
//            }
//        } else if let int32Data = buffer.int32ChannelData{
//            for channel in 0..<channelCount {
//                // Convert the data from int32 to float values before calculating the power values.
//                var floatChannelData: [Float] = Array(repeating: Float(0.0), count: Int(buffer.frameLength))
//                vDSP_vflt32(int32Data[channel], buffer.stride, &floatChannelData, buffer.stride, length)
//                var scalar = Float(INT32_MAX)
//                vDSP_vsdiv(floatChannelData, buffer.stride, &scalar, &floatChannelData, buffer.stride, length)
//
//                calculatePowers(data: floatChannelData, strideFrames: buffer.stride, length: length)
//            }
//        }
//    }
//
//    //buffer의 데이터의 상한선과 하한선을 결정한다.
//    private func calculatePowers(data:UnsafePointer<Float>,strideFrames:Int,length:vDSP_Length){
//        var max:Float = 0.0
//        vDSP_maxv(data, strideFrames, &max, length)
//        if max < 0.000_000_01{
//            max = 0.000_000_01
//        }
//
//        var rms:Float = 0.0
//        vDSP_rmsqv(data, strideFrames, &rms, length)
//        if rms < 0.000_000_01{
//            rms = 0.000_000_01
//        }
//
////        print(log10(rms))
////        print(log10(max))
//    }
}
