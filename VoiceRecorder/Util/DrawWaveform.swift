//
//  DrawWaveform.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/08.
//

import Foundation
import UIKit
import Accelerate
class DrawWaveform: UIView {
    
    var movePoitnt = CGPoint(x: 0.0, y: 0.0)
    
    override func draw(_ rect: CGRect) {
        self.convertToPoints()
        var f = 0
        
        let aPath = UIBezierPath()
        let aPath2 = UIBezierPath()
        
        aPath.lineWidth = 1.0
        aPath2.lineWidth = 1.0
        
        aPath.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height))
        
        for _ in readFile.points{
            var x:CGFloat = 300 / CGFloat(readFile.points.count)
            movePoitnt = CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y )
            aPath.move(to: CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y ))
            aPath.addLine(to: CGPoint(x:aPath.currentPoint.x  , y:aPath.currentPoint.y - (readFile.points[f] * 5) - 1.0))
            aPath.close()
            
            x += 1
            f += 1
        }
       
        UIColor.orange.set()
        aPath.stroke()
        aPath.fill()
        
        f = 0
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        
        for _ in readFile.points{
            var x:CGFloat = 300 / CGFloat(readFile.points.count)
            aPath2.move(to: CGPoint(x:aPath2.currentPoint.x + x , y:aPath2.currentPoint.y ))
            aPath2.addLine(to: CGPoint(x:aPath2.currentPoint.x  , y:aPath2.currentPoint.y - ((-1.0 * readFile.points[f] * 5))))
            aPath2.close()
            
            x += 1
            f += 1
        }
        
        UIColor.orange.set()
        aPath2.stroke()
        aPath2.fill()
    }
    
    func readArray( array:[Float]){
        readFile.arrayFloatValues = array
    }
    
    func convertToPoints() {
        var processingBuffer = [Float](repeating: 0.0,
                                       count: Int(readFile.arrayFloatValues.count))
        let sampleCount = vDSP_Length(readFile.arrayFloatValues.count)

        vDSP_vabs(readFile.arrayFloatValues, 1, &processingBuffer, 1, sampleCount);
        
        var multiplier = 1.0
        if multiplier < 1 { multiplier = 1.0 }

        let samplesPerPixel = Int(300 * multiplier)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel),
                             count: Int(samplesPerPixel))
        let downSampledLength = Int(readFile.arrayFloatValues.count / samplesPerPixel)
        var downSampledData = [Float](repeating:0.0,
                                      count:downSampledLength)
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(samplesPerPixel),
                    filter, &downSampledData,
                    vDSP_Length(downSampledLength),
                    vDSP_Length(samplesPerPixel))
        
        readFile.points = downSampledData.map{CGFloat($0) * 50}
    }
}
