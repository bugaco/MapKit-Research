//
//  UIViewExtension.swift
//  MapKit Research
//
//  Created by ZanyZephyr on 2022/3/29.
//

import Foundation
import UIKit

extension UIView {
    
    var width: CGFloat {
        get {
            frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
}
