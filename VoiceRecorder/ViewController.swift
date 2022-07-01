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
        setLayout()
        
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
    }
    
    func setLayout() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            plusButton.widthAnchor.constraint(equalToConstant: 80),
            plusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func plusButtonClicked() {
        
        let sheetViewController = VoicePlayingViewController()
        if let sheetController = sheetViewController.sheetPresentationController {
          sheetController.detents = [.medium()]
          sheetController.preferredCornerRadius = 4
          sheetController.prefersGrabberVisible = true
        }
        sheetViewController.fetchRecordedDataFromMainVC(data: nil)
        present(sheetViewController, animated: true, completion: nil)
        
    }
}

