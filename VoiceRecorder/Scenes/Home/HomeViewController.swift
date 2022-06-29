//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }

}

private extension HomeViewController {
    
    func setNavigationBar() {
        title = "Voice Memos"
        let audioCreationButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = audioCreationButton
    }
    
    @objc func didTapAddButton() {
        //TODO: Push AudioCreation VC
        print("clicked!")
    }
    
}

