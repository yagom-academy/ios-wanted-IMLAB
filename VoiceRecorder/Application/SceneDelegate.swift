//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: Coordinator!
    
    let audioManager = AudioManager()
    var pathFinder : PathFinder!
    let firebaseStorageManager = FirebaseStorageManager.init()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appWindow = UIWindow(frame:  windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene
        
        do {
            pathFinder = try PathFinder()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        audioManager.requestPermission()
        
        let navController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navController,audioManager: audioManager,pathFinder: pathFinder,firebasemanager: firebaseStorageManager)
        appCoordinator.start()
        
        appWindow.rootViewController = navController
        appWindow.makeKeyAndVisible()
        
        window = appWindow

    }


}

