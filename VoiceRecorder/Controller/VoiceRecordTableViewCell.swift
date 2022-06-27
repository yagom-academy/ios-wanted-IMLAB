//
//  VoiceRecordTableViewCell.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit

class VoiceRecordTableViewCell: UITableViewCell {
    
    let fileNameLabel : UILabel = {
        let fileNameLabel = UILabel()
        fileNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return fileNameLabel
    }()
    
    let timeLabel : UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return timeLabel
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setContentView()
        autoLayout()
    }
    
    func setContentView(){
        self.contentView.addSubview(fileNameLabel)
        self.contentView.addSubview(timeLabel)
    }
    
    func autoLayout(){
        NSLayoutConstraint.activate([
            fileNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fileNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
