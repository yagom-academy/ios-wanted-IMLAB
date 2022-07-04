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
            titleLabel.text = audio?.title
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension HomeTableViewCell {
    func configure() {
        addSubViews()
        makeConstraints()
    }
    
    func addSubViews() {
        contentView.addSubview(titleLabel)
    }
    
    func makeConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
