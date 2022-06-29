//
//  UIButton+.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit

extension UIButton {
    func setImage(systemName: String, state: UIControl.State) {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
        
        imageView?.contentMode = .scaleAspectFit
        
        setImage(UIImage(systemName: systemName), for: state)
    }
}
