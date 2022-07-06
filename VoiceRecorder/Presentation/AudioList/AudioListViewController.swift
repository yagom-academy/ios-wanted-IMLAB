//
//  AudioListViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class AudioListViewController: BaseViewController {
    
    private let audioListView = AudioListView()
    
    override func loadView() {
        self.view = audioListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupView() {
        audioListView.tableView.dataSource = self
    }
}

extension AudioListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioListTableViewCell.identifier, for: indexPath) as? AudioListTableViewCell else { return UITableViewCell() }
        
        return cell
    }
}
