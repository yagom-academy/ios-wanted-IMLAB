//
//  VoiceMemoCell.swift
//  VoiceRecorder
//
//  Created by jamescode on 2022/06/28.
//

import UIKit

class VoiceMemoCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "VoiceMemoCell"
    
    var fileTitleLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    var playTimeLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        designUI()
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Design

extension VoiceMemoCell {
    
    private func designUI() {
        contentView.addSubview(fileTitleLabel)
        NSLayoutConstraint.activate([
            fileTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fileTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        ])
        
        contentView.addSubview(playTimeLabel)
        NSLayoutConstraint.activate([
            playTimeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
}
