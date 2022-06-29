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
    let step:Float = 10
    var recorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer!
    var isPermissionGrant:Bool = false
    
    lazy var controlStackView:UIStackView = {
        let previusButton = UIButton()
        previusButton.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        previusButton.addTarget(self, action: #selector(previusSec), for: .touchUpInside)
        
        let playPauseButton = UIButton()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        
        let nextButton = UIButton()
        nextButton.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextSec), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [previusButton,playPauseButton,nextButton])
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    lazy var segmentedControl:UISegmentedControl = {
        let controller = UISegmentedControl(items: ["일반 목소리","아기 목소리","할아버지 목소리"])
        controller.selectedSegmentIndex = 0
        return controller
    }()
    
    @objc func previusSec(){
        print("tapped prev")
    }
    @objc func nextSec(){
        print("tapped next")
    }
    @objc func playPause(){
        print("Tapped play")
    }
    
    lazy var volumeBar:UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.setValue(50, animated: false)
        slider.addTarget(self, action: #selector(touchSlider(_:)), for: .editingDidEnd)
        return slider
    }()
    
    @objc func touchSlider(_ sender:UISlider!){
        let roundValue = round(sender.value / step) * step
        self.volumeBar.setValue(roundValue, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        checkPermission()
        setUpRecorder()
        
        [controlStackView,volumeBar,segmentedControl].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        controlStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        controlStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        controlStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        controlStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -50).isActive = true
        
        volumeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30).isActive = true
        volumeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30).isActive = true
        volumeBar.bottomAnchor.constraint(equalTo: controlStackView.topAnchor,constant: -50).isActive = true
        
        segmentedControl.leadingAnchor.constraint(equalTo: volumeBar.leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: volumeBar.trailingAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: volumeBar.topAnchor,constant: -30).isActive = true
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
    
    private func setUpRecorder(){
        if self.isPermissionGrant{
            let session = AVAudioSession.sharedInstance()
            
            let audioFileName = "voiceRecoders_\(convertString()).m4a"
            let directoryURL = FileManager.default.urls(for:.documentDirectory,in: .userDomainMask).first
            let audioFileURL = directoryURL!.appendingPathComponent(audioFileName)
            
            
            do{
                try session.setCategory(.playAndRecord,mode: .default)
            }catch let err{
                print("Error in Setup Recorder \(err)")
            }
            
            let setting = [
                AVFormatIDKey:NSNumber(value: kAudioFileMPEG4Type as UInt32),
                AVSampleRateKey:44100.0,
                AVNumberOfChannelsKey:2
            ]
            
            recorder = try? AVAudioRecorder(url: audioFileURL,settings: setting)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            
            print("Success Ready")
        }
    }
    
    private func convertString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: Date())
    }
}

extension RecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(flag)
    }
}
