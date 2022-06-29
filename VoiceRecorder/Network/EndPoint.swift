//
//  EndPoint.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/06/29.
//

import Foundation
import FirebaseStorage

struct EndPoint {
    static let reference = Storage.storage().reference()
    let fileName: String
    var path:  StorageReference {
        EndPoint.reference.child(fileName)
    }
}
