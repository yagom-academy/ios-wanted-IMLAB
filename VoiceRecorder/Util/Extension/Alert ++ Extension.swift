//
//  Alert ++ Extension.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/09.
//

import UIKit

extension UIViewController {
    typealias AlertActionHandler = ((UIAlertAction) -> Void)
    
    func alert(
        okHandler: AlertActionHandler? = nil,
        cancelHandler: AlertActionHandler? = nil) {
            
            let alert: UIAlertController = UIAlertController(title: "녹음한 파일을 저장하시겠어요?", message: nil, preferredStyle: .alert)
            
            if let okClosure = okHandler {
                let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: okClosure)
                alert.addAction(okAction)
                let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: cancelHandler)
                alert.addAction(cancelAction)
            }
            self.present(alert, animated: true)
        }
    
    func okAlert(title: String) {
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
