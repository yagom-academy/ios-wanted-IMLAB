//
//  FirebaseStorageDownloadManager.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/07/06.
//
protocol FirebaseDownloadManagerDelegate : AnyObject{
    func downloadComplete(url : URL)
}

import Foundation
import FirebaseStorage

class FirebaseStorageDownloadManager{
    private var fileName : String
    private var fileLength : String
    private var storageRef = Storage.storage().reference()
    private var downloadRef : StorageDownloadTask?
    private var localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myRecoding.m4a")
    private var imageRef : StorageReference?
    weak var delegate : FirebaseDownloadManagerDelegate?
    
    init(fileName : String, fileLength : String) {
        self.fileName = fileName
        self.fileLength = fileLength
        imageRef = storageRef.child("waveForm/\(fileName)WaveForm.png")
        
    }
    
    func downloadFile(){
        downloadRef = storageRef.child("record/\(fileName)@\(fileLength).m4a").write(toFile: localFileURL, completion: { url, error in
            self.imageRef?.downloadURL(completion: { url, error in
                self.delegate?.downloadComplete(url: url!)
            })
        } )
    }
    
    func cancelDownload(){
        downloadRef?.cancel()
    }
}
