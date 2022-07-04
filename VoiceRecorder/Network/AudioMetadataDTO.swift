//
//  AudioMetaData.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation
import FirebaseStorage

extension StorageMetadata {
    func toDomain() -> AudioRepresentation  {
        return AudioRepresentation(filename: self.name,
                                   createdDate: self.timeCreated ?? Date(),
                                   length: self.customMetadata?[CustomMetadata.fullLength])
    }
}

