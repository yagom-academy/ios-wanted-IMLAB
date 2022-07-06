//
//  RecordViewController.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class RecordViewController: UIViewController {
<<<<<<< HEAD
    
    let viewModel = TempRecordViewModel(PlayerManager.shared)
    
    let frequencyView = FrequencyView(frame: .zero)
=======

>>>>>>> feature-record
    let cutoffFrequencyView = CutoffFrequencyView(frame: .zero)
    let recordAndPlayView = RecordAndPlayView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        layout()
        bind()
    }
<<<<<<< HEAD
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.resetAudioPlayer()
    }
=======
>>>>>>> feature-record
}

extension RecordViewController {
    
    private func bind() {
        recordAndPlayView.bind(viewModel.playerButtonViewModel)
    }
    
    private func layout() {
        [
            cutoffFrequencyView,
            recordAndPlayView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cutoffFrequencyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        cutoffFrequencyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cutoffFrequencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cutoffFrequencyView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        
        recordAndPlayView.topAnchor.constraint(equalTo: cutoffFrequencyView.bottomAnchor).isActive = true
        recordAndPlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recordAndPlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recordAndPlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
