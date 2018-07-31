//
//  UIViewExtension.swift
//  MapTodo
//
//  Created by 福島瞳美 on 2018/07/29.
//  Copyright © 2018年 fukushima. All rights reserved.
//
// https://gist.github.com/funnything/1500a260a595e6d34da990ec4071f0d4
import Foundation
import UIKit

extension UIView {
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }

    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }

    var height: CGFloat {
        get {
            return size.height
        }
        set {
            size.height = newValue
        }
    }

    var left: CGFloat {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }

    var right: CGFloat {
        get {
            return left + width
        }
        set {
            left = newValue - width
        }
    }

    var top: CGFloat {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }

    var bottom: CGFloat {
        get {
            return top + height
        }
        set {
            top = newValue - height
        }
    }
}
