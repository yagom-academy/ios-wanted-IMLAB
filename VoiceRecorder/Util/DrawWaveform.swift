//
//  DrawWaveform.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/08.
//

import Foundation

import Foundation
import UIKit
import Accelerate
class DrawWaveform: UIView {
    
    var movePoitnt = CGPoint(x: 0.0, y: 0.0)
    
    override func draw(_ rect: CGRect) {
        self.convertToPoints()
        var f = 0
        print("draw")
        
        let aPath = UIBezierPath()
        let aPath2 = UIBezierPath()
        
        aPath.lineWidth = 1.0
        aPath2.lineWidth = 1.0
        
        aPath.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height ))
        
        
        // print(readFile.points)
        for _ in readFile.points{
                //separation of points
            var x:CGFloat = 300 / CGFloat(readFile.points.count)
            movePoitnt = CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y )
            aPath.move(to: CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y ))
                
                //Y is the amplitude
                aPath.addLine(to: CGPoint(x:aPath.currentPoint.x  , y:aPath.currentPoint.y - (readFile.points[f] * 5) - 1.0))
                
                aPath.close()
                
                //print(aPath.currentPoint.x)
                x += 1
                f += 1
        }
       
        //If you want to stroke it with a Orange color
        UIColor.orange.set()
        aPath.stroke()
        //If you want to fill it as well
        aPath.fill()
        
        
        f = 0
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        
        //Reflection of waveform
        for _ in readFile.points{
            var x:CGFloat = 300 / CGFloat(readFile.points.count)
            aPath2.move(to: CGPoint(x:aPath2.currentPoint.x + x , y:aPath2.currentPoint.y ))
            
            //Y is the amplitude
            aPath2.addLine(to: CGPoint(x:aPath2.currentPoint.x  , y:aPath2.currentPoint.y - ((-1.0 * readFile.points[f] * 5))))
            
            // aPath.close()
            aPath2.close()
            
            //print(aPath.currentPoint.x)
            x += 1
            f += 1
        }
        
        //If you want to stroke it with a Orange color with alpha2
        UIColor.orange.set()
        aPath2.stroke(with: CGBlendMode.normal, alpha: 0.5)
        //   aPath.stroke()
        
        //If you want to fill it as well
        aPath2.fill()
    }
    
    
    
    
    func readArray( array:[Float]){
        readFile.arrayFloatValues = array
    }
    
    func convertToPoints() {
        var processingBuffer = [Float](repeating: 0.0,
                                       count: Int(readFile.arrayFloatValues.count))
        let sampleCount = vDSP_Length(readFile.arrayFloatValues.count)
        //print(sampleCount)
        vDSP_vabs(readFile.arrayFloatValues, 1, &processingBuffer, 1, sampleCount);
        // print(processingBuffer)
        
        var multiplier = 1.0
        print(multiplier)
        if multiplier < 1{
            multiplier = 1.0
        }

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
        
        // print(" DOWNSAMPLEDDATA: \(downSampledData.count)")
        
        //convert [Float] to [CGFloat] array
        readFile.points = downSampledData.map{CGFloat($0) * 50}
        
        print(readFile.points)
    }
    
}
