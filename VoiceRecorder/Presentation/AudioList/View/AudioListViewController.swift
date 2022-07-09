//
//  AudioListViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class AudioListViewController: BaseViewController {
    
    private let audioListView = AudioListView()
    
    var backgroundView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    var viewModel: AudioListViewModel?
    var recordPermissionManager: RecordPermissionManageable?
    
    override func loadView() {
        self.view = audioListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setupView() {
        audioListView.tableView.dataSource = self
        audioListView.tableView.delegate = self
        
        title = "Voice Memos"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func bind() {
        viewModel?.downloadAll {
            DispatchQueue.main.async {
                self.detachActivityIndicator()
            }
        }
        
        viewModel?.audioInformation.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.audioListView.tableView.reloadData()
            }
        }
    }
    
    private func detachActivityIndicator() {
        if audioListView.activityIndicator.isAnimating {
            audioListView.activityIndicator.stopAnimating()
        }
        backgroundView.removeFromSuperview()
        audioListView.activityIndicator.removeFromSuperview()
    }
}

extension AudioListViewController {
    @objc func plusButtonTapped() {
        guard let recordPermissionManager = recordPermissionManager else { return }
        
        let recordingViewController = RecordingViewController()
        recordingViewController.viewModel = viewModel?.recordingViewModel
        recordingViewController.recordPermissionManager = recordPermissionManager
        
        self.present(recordingViewController, animated: true)
    }
    
    func presentPlayView(audioInformation: AudioInformation) {
        let playViewController = PlayViewController()
        let playViewModel = PlayViewModel(audioInformation: audioInformation)
        playViewController.viewModel = playViewModel
        
        self.present(playViewController, animated: true)
    }
}

extension AudioListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.audioInformation.value.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioListTableViewCell.identifier, for: indexPath) as? AudioListTableViewCell else { return UITableViewCell() }
        guard let viewModel = viewModel else { return UITableViewCell() }
        
        cell.configureCell(audioInformation: viewModel.audioInformation.value[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
}

extension AudioListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        self.presentPlayView(audioInformation: viewModel.audioInformation.value[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if editingStyle == .delete {
            viewModel.delete(name: viewModel.audioInformation.value[indexPath.row].name)
            viewModel.audioInformation.value.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

}
