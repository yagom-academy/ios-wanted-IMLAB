//
//  Extensions.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/28.
//

import UIKit
//UI

//Button
extension UIButton{
    func playControlButton(_ imageName:String...,state:UIControl.State...)->UIButton{
        let button = UIButton()
        for index in state.indices{
            button.setImage(UIImage(systemName: imageName[index]), for: state[index])
        }
        return button
    }
}

//UTILS
extension Date{
    func convertString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: self)
    }
}
