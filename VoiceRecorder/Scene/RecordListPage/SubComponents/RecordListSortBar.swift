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
    private let basicSortButton = UIButton()
    private let latestSortButton = UIButton()
    private let oldestSortButton = UIButton()
    private let favoriteSortButton = UIButton()
    
    var sortState: RecordListSortState = .basic
    
    init() {
        super.init(frame: CGRect.zero)
        
        attribute()
        layout()
        handleSortButton(sortState: sortState)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewWillAppear() {
        handleSortButton(sortState: sortState)
    }
    
    func cellChanged() {
        handleSortButton(sortState: .basic)
    }
    
    private func attribute() {
        //temp
        self.backgroundColor = YagomColor.two.uiColor
        self.layer.cornerRadius = 10
        
        containerStackView.axis = .horizontal
        containerStackView.distribution = .equalSpacing
        
        basicSortButton.setTitle("  기본순  ", for: .normal)
        basicSortButton.addTarget(self, action: #selector(handleBasicSortButton), for: .touchUpInside)
        
        latestSortButton.setTitle("  최신순  ", for: .normal)
        latestSortButton.addTarget(self, action: #selector(handleLatestSortButton), for: .touchUpInside)
        
        oldestSortButton.setTitle("  오래된순  ", for: .normal)
        oldestSortButton.addTarget(self, action: #selector(handleOldestSortButton), for: .touchUpInside)
        
        favoriteSortButton.setTitle("  즐겨찾기  ", for: .normal)
        favoriteSortButton.addTarget(self, action: #selector(handleFavoriteSortButton), for: .touchUpInside)
        
        [basicSortButton, latestSortButton, oldestSortButton, favoriteSortButton].forEach {
            $0.layer.cornerRadius = 10
        }
    }
    
    @objc private func handleBasicSortButton() {
        handleSortButton(sortState: .basic)
    }
    
    @objc private func handleLatestSortButton() {
        handleSortButton(sortState: .latest)
    }
    
    @objc private func handleOldestSortButton() {
        handleSortButton(sortState: .oldest)
    }
    
    @objc private func handleFavoriteSortButton() {
        handleSortButton(sortState: .favorite)
    }
    
    private func handleSortButton(sortState: RecordListSortState) {
        delegate?.sortButtonTapped(sortState: sortState)
        [basicSortButton, latestSortButton, oldestSortButton, favoriteSortButton].forEach {
            $0.backgroundColor = .clear
        }
        switch sortState {
        case .basic:
            self.basicSortButton.backgroundColor = YagomColor.three.uiColor
        case .latest:
            self.latestSortButton.backgroundColor = YagomColor.three.uiColor
        case .oldest:
            self.oldestSortButton.backgroundColor = YagomColor.three.uiColor
        case .favorite:
            self.favoriteSortButton.backgroundColor = YagomColor.three.uiColor
        }
        self.sortState = sortState
    }
    
    private func layout() {
        self.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        [UIView(), basicSortButton, latestSortButton, oldestSortButton, favoriteSortButton, UIView()].forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
}
