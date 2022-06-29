//
//  RecordListCell.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListCell: UITableViewCell {
    static let identifier = "RecordListCell"
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16))
    }
    
    func setData(filename: String) {
        self.titleLabel.text = filename
    }
    
    private func attribute() {
        self.selectionStyle = .none
        //temp
        self.contentView.backgroundColor = .purple
    }
    
    private func layout() {
        [titleLabel].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30).isActive = true
    }
}
