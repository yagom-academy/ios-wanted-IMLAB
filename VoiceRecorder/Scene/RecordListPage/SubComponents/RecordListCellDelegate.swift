//
//  RecordListCellDelegate.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/09.
//

import UIKit

protocol RecordListCellDelegate {
    func tappedFavoriteMark(_ indexPath: IndexPath)
    func beginSwapCellLongTapGesture(_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint)
}
