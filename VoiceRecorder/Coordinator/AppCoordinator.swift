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
    private var dependencies: Dependencies
    
    init(navigationController: UINavigationController,
         dependencies: Dependencies) {
        
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        
        let vc = VoiceMemoListViewController(
            pathFinder: dependencies.pathFinder,
            firebaseManager: dependencies.firebaseStorageManager
        )
        
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func presentRecordView() {
        
        let vc = VoiceMemoRecordViewController(
            pathFinder: dependencies.pathFinder,
            audioPlayer: dependencies.audioPlayer,
            audioRecorder: dependencies.audioRecoder,
            firebaseManager: dependencies.firebaseStorageManager
        )
        
        vc.isModalInPresentation = true
        navigationController.present(vc, animated: true)
    }
    
    func presentPlayView(selectedFile: String) {
        
        let vc = VoiceMemoPlayViewController(
            audioFileName: selectedFile,
            audioPlayer: dependencies.audioPlayer,
            pathFinder: dependencies.pathFinder,
            firebaseManager: dependencies.firebaseStorageManager
        )
        
        navigationController.present(vc, animated: true)
    }
    
}
