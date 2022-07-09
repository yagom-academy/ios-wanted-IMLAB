//
//  CustomMetaData.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/04.
//

import Foundation

struct CustomMetadata {
  let length: String

  func toDict() -> [String:String] {
    return [CustomMetadata.fullLength: length]
  }
}

extension CustomMetadata{
  static let fullLength = "fullLength"
  static let fileType = "audio/mpeg"
}
