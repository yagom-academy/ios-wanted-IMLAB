//
//  AudioRecorder.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/30.
//

import Foundation
import AVFAudio

class AudioRecorder {
    private var recorder: AVAudioRecorder?

    var averagePower: Float {
        recorder?.averagePower(forChannel: 0) ?? 0.0
    }
    var path: URL?
    var settings: [String: Any]?
    
    var url: URL? { recorder?.url }
    var data: Data? {
        if let url = url {
            do {
                return try Data(contentsOf: url)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func setupAudioRecorder() {
        guard let path = path,
              let settings = settings else { return }
        do {
            recorder = try AVAudioRecorder(url: path, settings: settings)
        } catch {
            return
        }
    }
    
    func record() {
        guard let recorder = recorder else { return }
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
    }
    func stop() {
        guard let recorder = recorder else { return }
        recorder.stop()
    }
    func deleteRecording() {
        guard let recorder = recorder else { return }
        recorder.deleteRecording()
    }
    func updateMeters() {
        recorder?.updateMeters()
    }
}
