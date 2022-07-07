//
//  RecordViewControllerDelegate.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/30.
//

import Foundation

protocol RecordViewControllerDelegate: AnyObject {
    func recordView(didFinishRecord: Bool)
    func recordView(cancelRecord: Bool)
}
