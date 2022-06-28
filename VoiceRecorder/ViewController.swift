//
//  ViewController.swift
//  VoiceRecorder
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNabBar()
    }
    
    func setupNabBar(){
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentRecordPage))
        navigationItem.rightBarButtonItem = rightButton
        
        navigationItem.title = "Table View"
    }
    
    @objc func presentRecordPage(){
        let rootViewController = RecordViewController()
        self.present(rootViewController, animated: true)
    }
}
