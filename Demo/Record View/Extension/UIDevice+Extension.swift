//
//  UIDevice+Extension.swift
//  Demo
//
//  Created by Appinventiv on 11/25/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import AVFoundation
import UIKit

// MARK:- UIDEVICE
//==================
extension UIDevice {
    
    /// Enum - NetworkTypes
    enum NetworkType: String {
        case _2G = "2G"
        case _3G = "3G"
        case _4G = "4G"
        case lte = "LTE"
        case wifi = "Wifi"
        case none = ""
    }
    
    static var size : CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var height : CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var width : CGFloat {
        return UIScreen.main.bounds.width
    }

    @available(iOS 11.0, *)
    static var bottomSafeArea : CGFloat {
        return UIApplication.shared.keyWindow!.safeAreaInsets.bottom
    }

    @available(iOS 11.0, *)
    static var topSafeArea : CGFloat {
        return UIApplication.shared.keyWindow!.safeAreaInsets.top
    }
    
    /// Device Model
    static var deviceModel : String {
        return UIDevice.current.model
    }
    
    /// OS Version
    static var osVersion : String {
        return UIDevice.current.systemVersion
    }
    
    /// Platform
    static var platform : String {
        return UIDevice.current.systemName
    }
    
    /// Device Id
    static var deviceId : String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
}
