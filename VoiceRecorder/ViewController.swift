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
    
    lazy var sampleButton: UIButton = {
        var button = UIButton()
        button.setTitle("sample", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        sampleButton.addTarget(self, action: #selector(sampleButtonClicked), for: .touchUpInside)
        
        FirebaseStorageManager.download(urlString: FirebaseStorageManager.url) { data in
            self.player(data: data!)
        }
    }
    
    func setLayout() {
        
        view.backgroundColor = .white
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        sampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(plusButton)
        view.addSubview(sampleButton)
        
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            plusButton.widthAnchor.constraint(equalToConstant: 80),
            plusButton.heightAnchor.constraint(equalToConstant: 50),
            
            sampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            sampleButton.widthAnchor.constraint(equalToConstant: 80),
            sampleButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    @objc func sampleButtonClicked() {
        let sampleVC = SampleViewController()
        self.present(sampleVC, animated: true)
    }
}
