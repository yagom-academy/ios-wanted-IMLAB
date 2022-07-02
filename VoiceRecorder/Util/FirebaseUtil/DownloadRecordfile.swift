//
//  DownloadRecordfile.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/28.
//

import Foundation
import FirebaseStorage

class DownloadRecordfile : FirebaseStoreDownload {
    func downloadFromFirebase(fileName: String, handler: @escaping (Result<String, Error>) -> ()) {
        let storageRef = Storage.storage().reference()
        let islandRef = storageRef.child("voiceRecords").child(fileName)
        
        let fileMnager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = fileMnager.appendingPathComponent(fileName)
        
        let downloadTask = islandRef.write(toFile: fileUrl) { url, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url = url {
                handler(.success(url.lastPathComponent))
            }
        }
        
        downloadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Download Fail", error.localizedDescription)
                return
            }
        }
    }
}
