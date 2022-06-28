//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/27.
//

import Foundation
import UIKit
import AVFoundation

class RecordViewController:UIViewController{
    let firebaseManger = FirebaseStorageManager.shared
    let step:Float = 10
    var recorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var isPermissionGrant:Bool = false
    
    public private(set) var isRecording = false
    
    lazy var controlStackView:UIStackView = {
        let recordButton = UIButton()
        recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        recordButton.addTarget(self, action: #selector(didTapRecord(_:)), for: .touchUpInside)
        
        let previusButton = UIButton()
        previusButton.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        previusButton.addTarget(self, action: #selector(previusSec), for: .touchUpInside)
        
        let playPauseButton = UIButton()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPause(_:)), for: .touchUpInside)
        
        let nextButton = UIButton()
        nextButton.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextSec), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [recordButton,previusButton,playPauseButton,nextButton])
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    @objc func didTapRecord(_ sender:UIButton){
        
        if isPermissionGrant{
            if let recorder = recorder {
                if !recorder.isRecording{
                    recodingVoice()
                    sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                }else{
                    stopRecord()
                    sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                }
            }

        }
        
    }
    @objc func previusSec(){
        print("tapped prev")
    }
    @objc func nextSec(){
        print("tapped next")
    }
    @objc func playPause(_ sender:UIButton){
        if let recorder = recorder {
            if !recorder.isRecording{
                audioPlayer = try? AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer?.delegate = self
                audioPlayer?.volume = volumeBar.value
                audioPlayer?.play()
            }
        }
    }
    
    lazy var volumeBar:UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.setValue(50, animated: false)
        slider.addTarget(self, action: #selector(touchSlider(_:)), for: .editingChanged)
        return slider
    }()
    
    @objc func touchSlider(_ sender:UISlider!){
        self.audioPlayer?.volume = sender.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        checkPermission()
        setupRecoder()
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
            volumeBar.bottomAnchor.constraint(equalTo: controlStackView.topAnchor,constant: -50)
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
    
    func setupRecoder(){
        let recordSettings = [AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ] as [String : Any]
        let session = AVAudioSession.sharedInstance()
        
        let directory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        let audioFileName = convertString() + ".m4a"
        let audioFileURL = directory!.appendingPathComponent(audioFileName)
        
        do{
            try session.setCategory(.playAndRecord)
        } catch {
            print("Could not setting session \(error)")
        }
        
        recorder = try? AVAudioRecorder(url: audioFileURL, settings: recordSettings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
    }
    
    func recodingVoice(){
        if let recoder = self.recorder{
            let session = AVAudioSession.sharedInstance()
            
            do{
                try session.setActive(true)
            } catch {
                print("Could not active recorder \(error)")
            }
            
            
            recoder.record()
        }

    }
    
    func stopRecord(){
        if let recoder = self.recorder{
            recoder.stop()
            let session = AVAudioSession.sharedInstance()
            do{
                try session.setActive(false)
            } catch {
                print("Could not stop record \(error)")
            }
            

        }
    }
    
    func playRecord(){
        if let recorder = recorder{
            if !recorder.isRecording{
                print("play")
                do{
                    audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                } catch {
                    print("Could not init player")
                }

                audioPlayer?.delegate = self
                audioPlayer?.play()
            }
        }
    }
    
    func stopPlay(){
        if let player = audioPlayer{
            if player.isPlaying{
                player.stop()
            }
        }
    }
    
    func convertString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: Date())
    }

}

extension RecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Did Record finish \(flag)")
        if flag{
            
            firebaseManger.uploadData(url: recorder.url, fileName:"\(convertString()).m4a")
        }
    }
}

extension RecordViewController:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
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
