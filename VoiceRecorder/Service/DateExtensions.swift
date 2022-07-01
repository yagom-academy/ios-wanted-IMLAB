//
//  Extensions.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/28.
//

import UIKit

//Date
//extension DateFormatter{
//    static var localFormat = "yyyy_MM_dd_HH:mm:ss"
//
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.setLocalizedDateFormatFromTemplate(localFormat)
//        return formatter
//    }()
//
//    static func toString(for date:Date, format:String) -> String{
//        if localFormat != format{
//            dateFormatter.setLocalizedDateFormatFromTemplate(format)
//            localFormat = format
//        }
//
//        return dateFormatter.string(from: date)
//    }
//}

extension Date {
    static let dateFormatter = DateFormatter()
    
    func toString(_ format:String) -> String{
        Self.dateFormatter.dateFormat = format
        Self.dateFormatter.locale = Locale(identifier: "ko_KR")
        return Self.dateFormatter.string(from: self)
    }
    
    
    // DateFormatter Statical 2
    //    static let dateFormatter:DateFormatter = {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
    //        dateFormatter.locale = Locale(identifier: "ko_KR")
    //        return dateFormatter
    //    }()
    //
    //    func toString(_ format:String) -> String{
    //        Self.dateFormatter.dateFormat = format
    //        return Self.dateFormatter.string(from: self)
    //    }
}

