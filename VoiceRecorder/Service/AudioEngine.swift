//
//  AudioEngine.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/28.
//

import Foundation
import AVFAudio

class AudioEngine{
    
    private var recordedFileURL:URL
    private var recordedFilePlayer = AVAudioPlayerNode()
    private var recordedFile: AVAudioFile?
    private var engine = AVAudioEngine()
    public private(set) var isRecording = false
    private var isNewRecordingAvailable = false


    enum AudioEngingError:Error{
        case bufferError
    }
    
    init(recordedFileUrl:URL){
        self.recordedFileURL = recordedFileUrl
        engine.attach(recordedFilePlayer)
    }
    
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
        do{
            let audioFile = try AVAudioFile(forReading: recordedFileURL)
            let format = audioFile.fileFormat
            engine.connect(recordedFilePlayer, to: output, format: format)
            engine.prepare()
        } catch{
            print("Could not read file \(error.localizedDescription)")
        }
    }
    
    private static func getBuffer(fileURL:URL)->AVAudioPCMBuffer?{
        let file:AVAudioFile!
        print(fileURL)
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
    
    func start(){
        do{
            try engine.start()
        } catch {
            print("Could not start engine: \(error)")
        }
    }
    
    func checkEngineRunning(){
        if !engine.isRunning{
            start()
        }
    }
    
    func toggleRecording(){
        if isRecording{
            isRecording = false
            recordedFile = nil
        }else{
            recordedFilePlayer.stop()
            
            do{
                recordedFile = try AVAudioFile(forWriting: recordedFileURL,settings: [:])
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
    
    func togglePlaying(){
        if recordedFilePlayer.isPlaying{
            recordedFilePlayer.pause()
        }else{
            if isNewRecordingAvailable{
                print(recordedFileURL)
                guard let recordedBuffer = AudioEngine.getBuffer(fileURL: recordedFileURL) else{return}
                
                recordedFilePlayer.scheduleBuffer(recordedBuffer,at: nil,options: .loops)
                isNewRecordingAvailable = false
            }
            
            recordedFilePlayer.play()
            
        }
    }
}

extension AudioEngine{
    func convertString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: Date())
    }
}
