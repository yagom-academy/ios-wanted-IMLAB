//
//  AudioListTableViewCell.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/06.
//

import UIKit

final class AudioListTableViewCell: UITableViewCell {
    
    static let identifier: String = "AudioListTableViewCell"
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "dateLabel"
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "time label"
        
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        [nameLabel, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

