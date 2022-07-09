//
//  Coordinator.swift
//  VoiceRecorder
//
//  Created by jamescode on 2022/06/30.
//

import Foundation
import UIKit

protocol Coordinator {
    
    var navigationController: UINavigationController { get set }
    
    func start()
}
