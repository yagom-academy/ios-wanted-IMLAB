//
//  AudioListView.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class AudioListView: UIView {
    
    lazy var tableView: UITableView = {
        lazy var tableView = UITableView()
        
        tableView.register(AudioListTableViewCell.self, forCellReuseIdentifier: AudioListTableViewCell.identifier)
        tableView.separatorInset.left = 15
        tableView.separatorInset.right = 15
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: self.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
           ])
    }
}
