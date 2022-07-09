//
//  BaseViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setupView()
    }
    
    func style() {
        view.backgroundColor = .white
    }
    
    func setupView() {}
}
