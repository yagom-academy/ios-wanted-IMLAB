//
//  VoiceMemoListViewCoordinator.swift
//  VoiceRecorder
//
//  Created by jamescode on 2022/06/30.
//

import Foundation
import UIKit

class AppCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = VoiceMemoListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func presentRecordView() {
        let vc = VoiceMemoRecordViewController()
        navigationController.present(vc, animated: true)
    }
    
    func presentPlayView() {
        let vc = VoiceMemoPlayViewController()
        navigationController.present(vc, animated: true)
    }
}
