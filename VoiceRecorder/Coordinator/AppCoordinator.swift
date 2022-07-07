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
    private weak var audioPlayer: AudioPlayable!
    private weak var audioRecoder: AudioRecodable!
    private weak var pathFinder: PathFinder!
    private weak var firebaseManager: FirebaseStorageManager!
    
    init(navigationController: UINavigationController,
         audioPlayer: AudioPlayable,
         audioRecoder: AudioRecodable,
         pathFinder: PathFinder,
         firebasemanager: FirebaseStorageManager) {
        
        self.navigationController = navigationController
        self.audioPlayer = audioPlayer
        self.audioRecoder = audioRecoder
        self.pathFinder = pathFinder
        self.firebaseManager = firebasemanager
    }
    
    func start() {
        
        let vc = VoiceMemoListViewController(pathFinder: pathFinder,
                                             firebaseManager: firebaseManager)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func presentRecordView() {
        
        let vc = VoiceMemoRecordViewController(pathFinder: pathFinder,
                                               audioPlayer: audioPlayer,
                                               audioRecorder: audioRecoder,
                                               firebaseManager: firebaseManager)
        vc.isModalInPresentation = true
        navigationController.present(vc, animated: true)
    }
    
    func presentPlayView(selectedFile: String) {
        
        let vc = VoiceMemoPlayViewController(audioFileName: selectedFile,
                                             audioPlayer: audioPlayer,
                                             pathFinder: pathFinder,
                                             firebaseManager: firebaseManager)
        navigationController.present(vc, animated: true)
    }
    
}
