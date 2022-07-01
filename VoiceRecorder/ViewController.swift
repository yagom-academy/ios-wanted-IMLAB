//
//  ViewController.swift
//  VoiceRecorder
//
import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var player: AVAudioPlayer?
    
    lazy var plusButton: UIButton = {
        var button = UIButton()
        button.setTitle("plus", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        
        FirebaseStorageManager.download(urlString: FirebaseStorageManager.url) { data in
            self.player(data: data!)
        }
        
        
    }
    
    func setLayout() {
        
        view.backgroundColor = .white
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            plusButton.widthAnchor.constraint(equalToConstant: 80),
            plusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func player(data: Data) {
        
        do {
            player = try AVAudioPlayer(data: data)
            
            print(player!.isPlaying)
            
        } catch {
            print("error")
        }
        
    }
    
    
    @objc func plusButtonClicked() {
        player!.play()
        //let recordCheckVC = RecordCheckViewController()
        //self.present(recordCheckVC, animated: true)
    }
}
