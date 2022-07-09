//
//  UIAlertController+.swift
//  VoiceRecorder
//
//

import UIKit

extension UIAlertController {
    static func showOKAlert(
        _ target: UIViewController,
        title: String,
        message: String,
        handler: ((UIAlertAction) -> Void)?
    ) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
        sheet.addAction(UIAlertAction.okAction(handler: handler))
        target.present(sheet, animated: true, completion: nil)
    }
    
    static func showCancelAlert(
        _ target: UIViewController,
        title: String,
        message: String,
        handler: ((UIAlertAction) -> Void)?
    ) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
        sheet.addAction(UIAlertAction.okAction(handler: handler))
        sheet.addAction(UIAlertAction.cancelAction())
        target.present(sheet, animated: true, completion: nil)
    }
}
