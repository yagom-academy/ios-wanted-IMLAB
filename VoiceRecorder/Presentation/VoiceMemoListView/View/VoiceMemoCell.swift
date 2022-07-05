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
    
    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var fileTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VoiceMemoCell {
    func configureUI() {
        contentView.addSubview(fileNameLabel)
        NSLayoutConstraint.activate([
            fileNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fileNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ])
        
        contentView.addSubview(fileTimeLabel)
        NSLayoutConstraint.activate([
            fileTimeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fileTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ])
    }
}
