//
//  FirebaseProtocol.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/28.
//

import Foundation


protocol FirebaseStoreUpload {
    func uploadToFirebase(fileUrl:URL,fileName:String)
}

protocol FirebaseStoreDownload {
    func downloadFromFirebase(fileUrl:URL,fileName:String)
}

protocol FirebaseStoreFileList {
    func getFirebaseStoreFileList() -> [String]
}

protocol FirebaseStoreDelete {
    func deleteOnTheFirebase(fileName:String)
}


