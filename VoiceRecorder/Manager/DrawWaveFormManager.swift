//
//  DrawWaveFormManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/29.
//

import UIKit
import AVFoundation

class DrawWaveFormManager{
    
    private var timer : Timer!
    
    func startDrawing(of recorder : AVAudioRecorder, in view : UIView){
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { timer in
            recorder.updateMeters() // 마이크 평균 및 최대 전력값을 업데이트
//            self.drawWaveForm(recorder.averagePower(forChannel: 0), in: view, true)
        })
    }
    
   
}
