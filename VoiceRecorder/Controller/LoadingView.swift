//
//  LoadingView.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/07/02.
//

import UIKit

class LoadingView: UIView {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let testLable : UILabel = {
        let label = UILabel()
        label.text = "로딩중 입니다. 잠시만 기다려주세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isLoading = false {
        didSet {
            self.isHidden = !self.isLoading
            self.isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.activityIndicatorView)
        self.addSubview(self.testLable)
        
        NSLayoutConstraint.activate([
            self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        NSLayoutConstraint.activate([
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.testLable.centerYAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor,constant: 30),
            self.testLable.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
