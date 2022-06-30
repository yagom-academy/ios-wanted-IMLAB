//
//  PathFinder.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/06/30.
//

import Foundation

class PathFinder {
    
    enum PathFinderError: Error {
        case initializeError
    }
    
    private let manager = FileManager.default
    private let baseAppDirPath = URL.init(fileURLWithPath: "/VoiceRecoder")
    
    var basePath: URL
    
    init() throws {
        var tempURL: URL!
        
        do {
            tempURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: baseAppDirPath, create: true)
        } catch {
            throw PathFinderError.initializeError
        }
        
        self.basePath = tempURL
    }
    
    func getPath(fileName: String) -> URL {
        let fileNameToAppend = "\(fileName)"
        var pathToReturn = basePath
        pathToReturn.appendPathComponent(fileNameToAppend)
        
        return pathToReturn
    }
    
    func getTimeNow() -> String {
        let timeNow = Date.now.formatted(
            Date.FormatStyle()
                .year(.defaultDigits)
                .month(.twoDigits)
                .day(.defaultDigits)
                .hour(.twoDigits(amPM: .abbreviated))
                .minute(.twoDigits)
                .second(.twoDigits))
        return timeNow
    }
    
    func getPathWithTime() -> URL {
        let converted = getTimeNow().components(separatedBy: "/").joined(separator: "_")
        
        return getPath(fileName: converted)
    }
    
}
