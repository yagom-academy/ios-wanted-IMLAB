//
//  FirebaseStorageManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/06/27.
//

import Foundation
import FirebaseCore
import FirebaseStorage

class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    private let storage = Storage.storage()
    private lazy var storageReference = storage.reference()
    
    private init() { }
    
}
