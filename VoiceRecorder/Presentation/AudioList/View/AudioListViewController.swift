//
//  AudioListViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class AudioListViewController: BaseViewController {
    
    private let audioListView = AudioListView()
    
    let viewModel = AudioListViewModel<FirebaseRepository>()
    
    override func loadView() {
        self.view = audioListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setupView() {
        audioListView.tableView.dataSource = self
    }
    
    private func bind() {
        viewModel.downloadAll()
        
        viewModel.audioInformation.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.audioListView.tableView.reloadData()
            }
        }
    }
}

extension AudioListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.audioInformation.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioListTableViewCell.identifier, for: indexPath) as? AudioListTableViewCell else { return UITableViewCell() }
        
        cell.configureCell(audioInformation: viewModel.audioInformation.value[indexPath.row])
        
        return cell
    }
}
