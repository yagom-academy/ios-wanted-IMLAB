//
//  RecordListSortBarView.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import UIKit

class RecordListSortBar: UIView {
    var delegate: RecordListSortBarDelegate?
    
    private let containerStackView = UIStackView()
    private let latestSortButton = UIButton()
    private let oldestSortButton = UIButton()
    
    init() {
        super.init(frame: CGRect.zero)
        
        attribute()
        layout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        //temp
        self.backgroundColor = YagomColor.two.uiColor
        self.layer.cornerRadius = 10
        
        containerStackView.axis = .horizontal
        containerStackView.distribution = .equalSpacing
        
        latestSortButton.setTitle("  최신순  ", for: .normal)
        latestSortButton.addTarget(self, action: #selector(handleLatestSortButton), for: .touchUpInside)
        
        oldestSortButton.setTitle("  오래된순  ", for: .normal)
        oldestSortButton.addTarget(self, action: #selector(handleOldestSortButton), for: .touchUpInside)
        
        [latestSortButton, oldestSortButton].forEach {
            $0.backgroundColor = YagomColor.three.uiColor
            $0.layer.cornerRadius = 10
        }
    }
    
    @objc private func handleLatestSortButton() {
        delegate?.sortButtonTapped(sortState: .latest)
    }
    
    @objc private func handleOldestSortButton() {
        delegate?.sortButtonTapped(sortState: .oldest)
    }
    
    private func layout() {
        self.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        [UIView(), latestSortButton, oldestSortButton, UIView()].forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
}
