//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        
        let rootViewController = AudioListViewController()
        let recordingViewModel = RecordingViewModel()
        let audioListViewModel = AudioListViewModel(recordingViewModel: recordingViewModel)
        let recordPermissionManager: RecordPermissionManageable = RecordPermissionManager()
        rootViewController.viewModel = audioListViewModel
        rootViewController.recordPermissionManager = recordPermissionManager
        window?.rootViewController = UINavigationController(
            rootViewController: rootViewController
        )
        
        window?.makeKeyAndVisible()
    }
}
