//
//  RecordVoiceViewController.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/27.
//

import UIKit

class RecordVoiceViewController: UIViewController {
        
    let waveGraphImageView : UIImageView = {
        let waveGraphImageView = UIImageView()
        waveGraphImageView.translatesAutoresizingMaskIntoConstraints = false
        return waveGraphImageView
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
        return record_start_stop_button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        autoLayout()
        setUI()
        
    }
    

    func setView() {
        self.view.addSubview(waveGraphImageView)
        
        self.view.addSubview(progressSlider)
        self.view.addSubview(progressTimeLabel)
        
        self.view.addSubview(buttonStackView)
        self.buttonStackView.addArrangedSubview(record_start_stop_button)
    }
    
    func autoLayout() {
        NSLayoutConstraint.activate([
            waveGraphImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 10),
            waveGraphImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            waveGraphImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.15),
            waveGraphImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            progressSlider.topAnchor.constraint(equalToSystemSpacingBelow: waveGraphImageView.bottomAnchor, multiplier: 2),
            progressSlider.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            progressSlider.heightAnchor.constraint(equalTo: waveGraphImageView.heightAnchor, multiplier: 0.5),
            progressSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            progressTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor),
            progressTimeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: progressTimeLabel.bottomAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            buttonStackView.heightAnchor.constraint(equalTo: waveGraphImageView.heightAnchor, multiplier: 0.9),
            buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            record_start_stop_button.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor),
            record_start_stop_button.widthAnchor.constraint(equalTo: record_start_stop_button.heightAnchor)
        ])
    }
    

    func setUI() {
        waveGraphImageView.image = UIImage(systemName: "square.fill")
        progressSlider.tintColor = .blue
        progressSlider.value = 0.5
        progressTimeLabel.text = "00:00:00"
        record_start_stop_button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        record_start_stop_button.tintColor = .red
    }

}
