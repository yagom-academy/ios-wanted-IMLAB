//
//  RecordVoiceViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class RecordVoiceViewController: UIViewController {

    var recordVoiceManager = RecordVoiceManager()
        
    let waveFormView : UIView = {
        let waveFormView = UIView()
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
        return waveFormView
    }()
    
    let progressSlider : UISlider = {
        let progressSlider = UISlider()
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        return progressSlider
    }()
    
    let progressTimeLabel : UILabel = {
        let progressTimeLabel = UILabel()
        progressTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return progressTimeLabel
    }()
    
    let buttonStackView : UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
//        buttonStackView.spacing = 5 // 아직 해당 스택뷰에 하위 뷰가 하나뿐이므로
        return buttonStackView
    }()
    
    let record_start_stop_button : UIButton = {
        let record_start_stop_button = UIButton()
        record_start_stop_button.translatesAutoresizingMaskIntoConstraints = false
        record_start_stop_button.addTarget(self, action: #selector(tab_record_start_stop_Button), for: .touchDown)
        return record_start_stop_button
    }()
    
    @objc func tab_record_start_stop_Button() {
        if recordVoiceManager.isRecording() {
            recordVoiceManager.stopRecording()
            record_start_stop_button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            record_start_stop_button.tintColor = .red
            print("recording stop")
        } else {
            recordVoiceManager.startRecording()
            record_start_stop_button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            record_start_stop_button.tintColor = .black
            print("recording start")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        autoLayout()
        setUI()
    }
    
    func setView() {
        self.view.addSubview(waveFormView)
        
        self.view.addSubview(progressSlider)
        self.view.addSubview(progressTimeLabel)
        
        self.view.addSubview(buttonStackView)
        self.buttonStackView.addArrangedSubview(record_start_stop_button)
    }
    
    func autoLayout() {
        NSLayoutConstraint.activate([
            waveFormView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 10),
            waveFormView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            waveFormView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.15),
            waveFormView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            progressSlider.topAnchor.constraint(equalToSystemSpacingBelow: waveFormView.bottomAnchor, multiplier: 2),
            progressSlider.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            progressSlider.heightAnchor.constraint(equalTo: waveFormView.heightAnchor, multiplier: 0.5),
            progressSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            progressTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor),
            progressTimeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: progressTimeLabel.bottomAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            buttonStackView.heightAnchor.constraint(equalTo: waveFormView.heightAnchor, multiplier: 0.9),
            buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            record_start_stop_button.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor),
            record_start_stop_button.widthAnchor.constraint(equalTo: record_start_stop_button.heightAnchor)
        ])
    }
    
    func setUI() {
        progressSlider.tintColor = .blue
        progressSlider.value = 0.5
        progressTimeLabel.text = "00:00:00"
        record_start_stop_button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        record_start_stop_button.tintColor = .red
    }

}
