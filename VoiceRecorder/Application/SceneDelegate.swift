//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: Coordinator!
    
    let audioPlayer = DefaultAudioPlayer()
    let audioRecoder = DefaultAudioRecoder()
    let firebaseStorageManager = FirebaseStorageManager.init()
    var pathFinder : PathFinder!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appWindow = UIWindow(frame:  windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene
        
        do {
            pathFinder = try PathFinder()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        requestPermission()
        
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController,
                                        audioPlayer: audioPlayer,
                                        audioRecoder: audioRecoder,
                                        pathFinder: pathFinder,
                                        firebasemanager: firebaseStorageManager)
        appCoordinator.start()
        
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        
        window = appWindow

    }
    
    private func configureAudioSession() {
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
            try session.setActive(true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func requestPermission() {
        
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission() { [unowned self] isGranted in
            if isGranted {
                configureAudioSession()
            }
        }
    }


}

