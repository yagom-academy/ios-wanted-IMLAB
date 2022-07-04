//
//  DeleteRecordfile.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/28.
//

import Foundation
import FirebaseStorage

class DeleteRecordfile : FirebaseStoreDelete {
    func deleteOnTheFirebase(fileName: String) {
        let storageRef = Storage.storage().reference()
        let desertRef = storageRef.child("voiceRecords").child(fileName)
        desertRef.delete { error in
          if let error = error {
              print(error.localizedDescription)
              return
          } 
        }
    }
}
