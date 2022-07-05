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
    
    var lastUsedUrl: URL!
    var lastUsedFileName: String!
    
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
        let fileNameToAppend = "\(fileName).caf"
        var pathToReturn = basePath
        pathToReturn.appendPathComponent(fileNameToAppend)
        
        lastUsedUrl = pathToReturn
        return pathToReturn
    }
    
    func getTimeNow() -> String {
        let timeNow = Date.now.formatted(
            Date.FormatStyle()
                .year(.defaultDigits)
                .month(.twoDigits)
                .day(.twoDigits)
                .hour(.twoDigits(amPM: .abbreviated))
                .minute(.twoDigits)
                .second(.twoDigits))
        return timeNow
    }
    
    func getPathWithTime() -> URL {
        let converted = getTimeNow().components(separatedBy: "/").joined(separator: "_")
        lastUsedFileName = converted
        let path = getPath(fileName: converted)
        
        lastUsedUrl = path
        return path
    }
    
}
