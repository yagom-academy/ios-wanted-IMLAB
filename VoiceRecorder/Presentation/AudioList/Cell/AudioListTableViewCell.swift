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
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "dateLabel"
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
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
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: self.timeLabel.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configureCell(audioInformation: AudioInformation) {
        
        guard let duration = audioInformation.duration else { return }
        
        let minute = Int(duration / 60.0)
        let seconds = Int(Int(duration) % 60)
        
        nameLabel.text = audioInformation.name
        timeLabel.text = "\(String(format: "%02d", minute)):\(String(format: "%02d", seconds))"
    }
}
