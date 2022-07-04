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
    private weak var audioManager: AudioManager!
    private weak var pathFinder: PathFinder!
    private weak var firebaseManager: FirebaseStorageManager!
    
    init(navigationController: UINavigationController,
         audioManager: AudioManager,
         pathFinder: PathFinder,
         firebasemanager: FirebaseStorageManager) {
        self.navigationController = navigationController
        self.audioManager = audioManager
        self.pathFinder = pathFinder
        self.firebaseManager = firebasemanager
    }
    
    func start() {
        let vc = VoiceMemoListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func presentRecordView() {
        let vc = VoiceMemoRecordViewController()
        vc.isModalInPresentation = true
        navigationController.present(vc, animated: true)
    }
    
    func presentPlayView(selectedFile: String) {
        let vc = VoiceMemoPlayViewController(audioFileName: selectedFile,
                                             audioManager: audioManager,
                                             pathFinder: pathFinder,
                                             firebaseManager: firebaseManager)
        navigationController.present(vc, animated: true)
    }
}
