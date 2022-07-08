//
//  RecordViewController.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

class RecordViewController: UIViewController {
    
    let viewModel = RecordViewModel(PlayerManager.shared, RecordManager.shared, RecordNetworkManager.shared)
    
    let frequencyView = FrequencyView(frame: .zero)
    let cutoffFrequencyView = CutoffFrequencyView(frame: .zero)
    let recordControllerView = RecordControllerView()
    let playControllerView = PlayControllerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.title = "음성 녹음"
        
        attribute()
        layout()
        bind()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewModel.resetAudioPlayer()
        viewModel.resetRecorder()
    }
}

extension RecordViewController {
    
    private func attribute() {
        recordControllerView.delegate = self
    }
    
    private func bind() {
        recordControllerView.bind(viewModel.recordControllerViewModel)
        playControllerView.bind(viewModel.playControllerViewModel)
    }
    
    private func layout() {
        [
            frequencyView,
            cutoffFrequencyView,
            recordControllerView,
            playControllerView
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
        
        recordControllerView.topAnchor.constraint(equalTo: cutoffFrequencyView.bottomAnchor).isActive = true
        recordControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recordControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recordControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        playControllerView.centerXAnchor.constraint(equalTo: recordControllerView.centerXAnchor).isActive = true
        playControllerView.centerYAnchor.constraint(equalTo: recordControllerView.centerYAnchor).isActive = true
    }
}

//MARK: - RecordController delegate
extension RecordViewController: RecordControllerDelegate {
    func startRecord() {
        playControllerView.isHidden = true
    }
    
    func endRecord() {
        playControllerView.isHidden = false
    }
    
    func completeUpload() {
        self.navigationController?.popViewController(animated: true)
    }
}
