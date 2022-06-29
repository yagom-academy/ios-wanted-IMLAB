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
    func downloadFromFirebase(fileName:String, handler: @escaping (Result<String , Error>) -> ())
}

protocol FirebaseStoreFileList {
    func getFirebaseStoreFileList() -> [String]
}

protocol FirebaseStoreDelete {
    func deleteOnTheFirebase(fileName:String)
}


