//
//  WaveFromGenerator.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/07/09.
//

import UIKit
import AVFoundation

final class WaveFormGenerator {
    
    func generateWaveImage(from audioURL: URL, in imageSize: CGSize) -> UIImage? {
        let samples = readBuffer(audioURL)
        let waveImage = generateWaveImage(samples, imageSize, UIColor.systemRed, UIColor.systemGray6)
        return waveImage
    }
    
    private func readBuffer(_ audioURL: URL) -> [Float] {
        guard let file = try? AVAudioFile(forReading: audioURL) else { return [] }
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFormat,
            frameCapacity: audioFrameCount
        ) else { return [] }
        
        do {
            try file.read(into: buffer)
        } catch {
            print(error.localizedDescription)
        }
        
        let bufferPointers = Array(
            UnsafeBufferPointer(
                start: buffer.floatChannelData![0],
                count: Int(buffer.frameLength / 1500)
            )
        )
        
        return bufferPointers
    }
    
    private func generateWaveImage(
        _ samples: [Float],
        _ imageSize: CGSize,
        _ strokeColor: UIColor,
        _ backgroundColor: UIColor
    ) -> UIImage? {
        let drawingRect = CGRect(origin: .zero, size: imageSize)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let middleY = imageSize.height / 2
        
        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(backgroundColor.cgColor)
        context.setAlpha(1.0)
        context.fill(drawingRect)
        context.setLineWidth(1.8)
        
        let max: CGFloat = CGFloat(samples.max() ?? 0)
        let heightNormalizationFactor = imageSize.height / max / 4
        let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
        for index in 0 ..< samples.count {
            let pixel = CGFloat(samples[index]) * heightNormalizationFactor
            
            let x = CGFloat(index) * widthNormalizationFactor
            
            context.move(to: CGPoint(x: x, y: middleY - pixel))
            context.addLine(to: CGPoint(x: x, y: middleY + pixel))
            context.setStrokeColor(strokeColor.cgColor)
            context.strokePath()
        }
        guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        UIGraphicsEndImageContext()
        return soundWaveImage
    }
}
