//
//  RecordViewModel.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/02.
//

import Foundation
import AVFAudio
import Combine
import FirebaseStorage
import QuartzCore

protocol RecordDrawDelegate: AnyObject{
    func updateValue(_ value:CGFloat)
    func clearAll()
    func uploadSuccess()
}

class RecordViewModel {
    let storage = FirebaseStorageManager.shared
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    let recordFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 1, interleaved: true)
    let recordFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("input.m4a"))
    
    private var displayLink: CADisplayLink?
    
    let timer = Timer.publish(every: 1.0, on: .current, in: .default).autoconnect()
    
    @Published var progressValue: Float = 0
    @Published var isPlaying: Bool = false
    @Published var isRecording: Bool = false
    @Published var number: Int = 0
    @Published var recordedTime: PlayerTime = .zero
    
    private var cancellable = Set<AnyCancellable>()
    
    weak var delegate: RecordDrawDelegate?

    
    init() {
        prepareRecorder()
        setupDisplayLink()
    }
    
    func prepareRecorder() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            // TODO: - !
            recorder = try AVAudioRecorder(url: recordFileURL, format: recordFormat!)
            recorder.prepareToRecord()

            print(recorder.settings)
        } catch {
            print("Error in prepare Recoder")
            print("Could not Prepare Recorder \(error)")
        }
    }
    
    func startRec() {
        recorder.record()
        recorder.isMeteringEnabled = true
        isRecording = recorder.isRecording
        
        startTimer()
        delegate?.clearAll()
        
        DispatchQueue.global(qos: .background).async {
            while self.recorder.isRecording {
                self.recorder.updateMeters()
                self.delegate?.updateValue(self.nomalizeSoundLevel(level: self.recorder.averagePower(forChannel: 0)))
            }
        }
        
    }
    
    func stopRec() {
        timer.upstream.connect().cancel()
        recorder.stop()
        isRecording = recorder.isRecording
        
        // 원래 녹음 파일을 가지고 있다 -> 지우고 다시 업로드
        // 지금은 그냥 업로드되고 나시 녹음해도 업로드되고 있지 않음
        // fileName으로 삭제 업데이트 이루어짐
        let title = DateFormatter().toString(Date())
        let fileName = title + ".m4a"
        
//        print(fileName)
        
//        if previousFileName == "" {
//            storage.uploadData(url: recordFileURL, fileName: fileName)
//        } else {
//            storage.replaceData(title: previousFileName, url: recordFileURL, fileName: fileName)
//            storage.deleteData(title: previousFileName)
        storage.uploadData(url: recordFileURL, fileName: fileName) {
            self.delegate?.uploadSuccess()
        }
//        }
        
//        previousFileName = fileName
        
//        storage.uploadData(url: recordFileURL, fileName: DateFormatter().toString(Date()) + ".m4a")
    }
    
    func setupAudio() {
        do {
            player = try AVAudioPlayer(data: getDataFrom())
            player.numberOfLoops = 0
        } catch {
            print("Fail to play audio")
        }
    }
    
    func playAudio() {
//        if player.data == nil {
            setupAudio()
//        }
        
        player.volume = 0.5
        player.play()
        displayLink?.isPaused = false
        isPlaying = player.isPlaying
    }
    
    
    func stopAudio() {
        player.pause()
        isPlaying = false
        displayLink?.isPaused = true
    }
    
    func getDataFrom() -> Data {
        guard let data = try? Data(contentsOf: recordFileURL) else {
            print("Data is Not Unwrapping")
            return Data()
        }
        return data
    }
    
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.isPaused = true
    }
    
    func seek(front:Bool){
        displayLink?.isPaused = true
        
        player.pause()
        
        var currentTime = player.currentTime
        currentTime += front ? 5:-5
        
        updateDisplay()
        
        if currentTime > player.duration {
            stopAudio()
            player.currentTime = 0
        } else {
            player.currentTime = currentTime
            player.play()
            isPlaying = player.isPlaying
        }
        
        displayLink?.isPaused = false
    }
    
    @objc private func updateDisplay() {
        let currentPosition = player.currentTime
        let totalPosition = player.duration
        isPlaying = player.isPlaying
        
        progressValue = Float(currentPosition) / Float(totalPosition)
    }
    
    func startTimer() {
        timer
            .scan(0) { counter, _ in
                counter + 1
            }
            .sink { counter in
                self.recordedTime = PlayerTime(elapsedTime: counter, remainingTime: 0)
            }
            .store(in: &cancellable)
    }
    
    @objc func timerCallBack() {
        number += 1
    }
    
    private func nomalizeSoundLevel(level:Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        return CGFloat(level * (350 / 25))
    }
}
