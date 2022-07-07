//
//  UIAlertAction+.swift
//  VoiceRecorder
//

import UIKit

extension UIAlertAction {
    static func okAction(handler: ( (UIAlertAction) -> Void)?) -> UIAlertAction {
        return UIAlertAction(title: "OK", style: .default, handler: handler)
    }
    
    static func cancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel)
    }
}
