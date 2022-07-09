//
//  FirebaseStorageDelete.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/09.
//

import Foundation

class FirebaseStorageDelete {
    var deleteHandler : FirebaseStoreDelete
    
    init(_ firebaseStoreDelete : FirebaseStoreDelete) {
        self.deleteHandler = firebaseStoreDelete
    }
    
    func deleteFile(fileName:String) {
        deleteHandler.deleteOnTheFirebase(fileName: fileName)
    }
}
