//
//  UIView.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/04.
//

import UIKit

extension UIView {
    func snapshotCellStyle() -> UIView {
        let image = snapshot()
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

    private func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        return image
    }
}
