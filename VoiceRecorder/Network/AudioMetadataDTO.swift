//
//  AudioMetaData.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation
import FirebaseStorage

enum CustomMetadata: String {
    case FullLength
}

extension StorageMetadata {
    func toDomain() -> AudioRepresentation  {
        return AudioRepresentation(filename: self.name ?? "",
                                   createdDate: MyDateFormatter.shared.calendarDateString(from: self.timeCreated!),
                                   length: self.customMetadata?[CustomMetadata.FullLength.rawValue] ?? "0:0")
    }
}

