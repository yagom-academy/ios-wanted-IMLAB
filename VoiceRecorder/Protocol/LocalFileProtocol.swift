//
//  LocalFileProtocal.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/30.
//

import Foundation

protocol LocalFileProtocol {
    var localFileURL : URL { get set }
    func getFileDate(file: URL) -> Date
    func getFileName() -> String
}
