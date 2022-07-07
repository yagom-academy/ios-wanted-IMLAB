//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayViewController: BaseViewController {
    
    private let playView = PlayView()
    var viewModel: PlayViewModel?
    
    override func loadView() {
        self.view = playView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
