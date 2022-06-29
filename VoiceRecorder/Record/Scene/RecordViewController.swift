//
//  RecordViewController.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class RecordViewController: UIViewController {
    
    let frequencyView = FrequencyView(frame: .zero)
    let cutoffFrequencyView = CutoffFrequencyView(frame: .zero)
    let recordAndPlayView = RecordAndPlayView(frame: .zero)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecordViewController {
    private func layout() {
        [
            frequencyView,
            cutoffFrequencyView,
            recordAndPlayView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        frequencyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        frequencyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        frequencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        frequencyView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        
        cutoffFrequencyView.topAnchor.constraint(equalTo: frequencyView.bottomAnchor).isActive = true
        cutoffFrequencyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cutoffFrequencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cutoffFrequencyView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        
        recordAndPlayView.topAnchor.constraint(equalTo: cutoffFrequencyView.bottomAnchor).isActive = true
        recordAndPlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recordAndPlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recordAndPlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
