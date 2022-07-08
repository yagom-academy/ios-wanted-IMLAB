//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: Coordinator!
    var dependencies : Dependencies!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appWindow = UIWindow(frame:  windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene
        
        
        requestPermission()
        
        dependencies = makeDependencies()
        
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController,
                                        dependencies: dependencies)
        appCoordinator.start()
        
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        
        window = appWindow

    }
    
    private func makeDependencies() -> Dependencies {
        
        let audioPlayer = DefaultAudioPlayer()
        let audioRecoder = DefaultAudioRecoder()
        let firebaseStorageManager = FirebaseStorageManager.init()
        var pathFinder : PathFinder!
        
        do {
            pathFinder = try PathFinder()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        
        return Dependencies.init(audioRecoder: audioRecoder,
                                 audioPlayer: audioPlayer,
                                 firebaseStorageManager: firebaseStorageManager,
                                 pathFinder: pathFinder)
        
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
    
    private func requestPermission() {
        
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission() { [unowned self] isGranted in
            if isGranted {
                configureAudioSession()
            }
        }
    }

}

