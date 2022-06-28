//
//  BaseViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/28.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        style()
    }
    
    func setupView() {}
    
    func style() {
        view.backgroundColor = .white
    }
}
