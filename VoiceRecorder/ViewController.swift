//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ViewController: UIViewController {
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = .gray
        label.textColor = .white
        label.text = "Example"
        label.textAlignment = .center
        label.layer.cornerRadius = 20
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
