//
//  HomeTableViewCell.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/27.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    static let identfier = String(describing: HomeTableViewCell.self)
    
    var audio: Audio? {
        didSet {
            self.titleLabel.text = audio?.title
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension HomeTableViewCell {
    func configure() {
        self.addSubViews()
        self.makeConstraints()
    }
    
    func addSubViews() {
        self.contentView.addSubview(self.titleLabel)
    }
    
    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16.0),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16.0),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
    }
}
