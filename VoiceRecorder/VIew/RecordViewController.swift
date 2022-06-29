//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/27.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class RecordViewController:UIViewController{
    let firebaseManger = FirebaseStorageManager.shared
    let step:Float = 10
    var recorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var player:AVQueuePlayer!
    var playerLooper:AVPlayerLooper!
    var isPermissionGrant:Bool = false
    
    public private(set) var isRecording = false
    private var audioEngine: AudioEngine!
    var engine:AudioEngine?
    
    lazy var recordButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapRecord(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var prevButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        button.addTarget(self, action: #selector(previusSec), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    lazy var nextButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        button.addTarget(self, action: #selector(nextSec), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    lazy var playButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(playPause(_:)), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    lazy var controlStackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordButton,prevButton,playButton,nextButton])
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    @objc func didTapRecord(_ sender:UIButton){
        if isPermissionGrant{
            audioEngine.checkEngineRunning()
            audioEngine.toggleRecording()
            
            if audioEngine.isRecording{
                sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                playButton.isEnabled = false
                prevButton.isEnabled = false
                nextButton.isEnabled = false
            }else{
                sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                playButton.isEnabled = true
                prevButton.isEnabled = true
                nextButton.isEnabled = true
                audioEngine.firebaseUpload()
            }
        }else{
            sender.isEnabled = false
        }
        
        //TODO: - Permission denied
        
    }
    @objc func previusSec(){
        print("pre Tapped")
    }
    @objc func nextSec(){
        print("next Tapped")
    }
    @objc func playPause(_ sender:UIButton){
        audioEngine.checkEngineRunning()
        audioEngine.togglePlaying {
            DispatchQueue.main.async {
                
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
        
        if audioEngine.isPlaying{
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }else{
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    lazy var volumeBar:UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.setValue(50, animated: false)
        slider.addTarget(self, action: #selector(touchSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    @objc func touchSlider(_ sender:UISlider!){
        self.player?.volume = sender.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        checkPermission()
        setupAudioEngine()
        configure()
    }
}

//MARK: - View Configure
private extension RecordViewController{
    func configure(){
        addSubViews()
        makeConstrains()
    }
    
    func addSubViews(){
        
        [controlStackView,volumeBar].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func makeConstrains(){
        NSLayoutConstraint.activate([
            controlStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            controlStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -50),
            
            volumeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            volumeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30),
            volumeBar.bottomAnchor.constraint(equalTo: controlStackView.topAnchor,constant: -50),
        ])
    }
}

extension RecordViewController{
    private func checkPermission(){
        switch AVAudioSession.sharedInstance().recordPermission{
        case .granted:
            isPermissionGrant = true
        case .denied:
            isPermissionGrant = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                self.isPermissionGrant = allowed
            }
        @unknown default:
            fatalError("Error in permission")
        }
    }
    
    func setupAudioEngine(){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            audioEngine = try AudioEngine()
            try audioSession.setCategory(.playAndRecord,options: .defaultToSpeaker)
            
            audioEngine.setup()
            audioEngine.start()
        } catch {
            print("Could not setup engine \(error)")
        }
    }
}

extension RecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Did Record finish \(flag)")
        if flag{
            let playItem = AVPlayerItem(url: recorder.url)
            player = AVQueuePlayer(playerItem: playItem)
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playItem)
            firebaseManger.uploadData(url: recorder.url, fileName:"\(Date().convertString()).m4a")
        }
    }
}


//MARK: - PREVIEWS
#if canImport(swiftUI) && DEBUG
import SwiftUI

struct RecordViewController_Previews:PreviewProvider{
    static var previews: some View{
        RecordViewController().showPreview()
    }
}
#endif
