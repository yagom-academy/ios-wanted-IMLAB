//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit
import FirebaseStorage
import AVFoundation

class ViewController: UIViewController {
   
    var player = AVPlayer()
    var item : [StorageReference] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let storage = Storage.storage()
        let reference = storage.reference()
        
        
        reference.listAll { result, error in
            if let error = error {
              print(error)
              return
            }
            
            guard let result = result else {
                print("nodata")
                return
            }
            for item in result.items {
                self.item.append(item)
                
            }
            // Fetch the download URL
            self.item.first!.downloadURL { url, error in
                if let error = error {
                    
                } else {
                    // Get the download URL for 'images/stars.jpg'
                    print("url : \(url)")
                    let playerItem = AVPlayerItem(url: url!)
                    print(playerItem)
                    self.player = AVPlayer(playerItem: playerItem)
                    self.player.play()
                }
            }
        }

    }


}

