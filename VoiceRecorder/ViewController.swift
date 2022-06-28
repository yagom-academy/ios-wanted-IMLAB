//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ViewController: UIViewController {

    lazy var plusButton: UIButton = {
        var button = UIButton()
        button.setTitle("plus", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
    }
    
    @objc func plusButtonClicked() {
        let recordCheckVC = RecordCheckViewController()
        self.present(recordCheckVC, animated: true)
    }
}

