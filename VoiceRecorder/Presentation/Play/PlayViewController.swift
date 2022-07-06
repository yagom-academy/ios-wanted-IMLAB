//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/06/29.
//

import UIKit

final class PlayViewController: BaseViewController {
    
    private let playView = PlayView()
    
    override func loadView() {
        self.view = playView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
