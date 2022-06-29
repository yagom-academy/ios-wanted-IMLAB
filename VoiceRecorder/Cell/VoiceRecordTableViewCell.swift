//
//  VoiceRecordTableViewCell.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/27.
//

import UIKit

class VoiceRecordTableViewCell: UITableViewCell {
    
    static let g_identifier = "VoiceRecordListCell"
    
    let createVoiceRecordDateLable : UILabel = {
        let createVoiceRecordDateLable = UILabel()
        createVoiceRecordDateLable.translatesAutoresizingMaskIntoConstraints = false
        createVoiceRecordDateLable.font = UIFont.boldSystemFont(ofSize: 15)
        return createVoiceRecordDateLable
    }()
    
    let voiceRecordLengthLabel : UILabel = {
        let voiceRecordLengthLabel = UILabel()
        voiceRecordLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceRecordLengthLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return voiceRecordLengthLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setContentView()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setContentView()
        autoLayout()
    }
    
    func setContentView(){
        self.contentView.addSubview(createVoiceRecordDateLable)
        self.contentView.addSubview(voiceRecordLengthLabel)
    }
    
    func autoLayout(){
        NSLayoutConstraint.activate([
            createVoiceRecordDateLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            createVoiceRecordDateLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            voiceRecordLengthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            voiceRecordLengthLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
