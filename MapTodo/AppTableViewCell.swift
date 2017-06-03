//
//  AppTableViewCell.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/05/15.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {
    @IBInspectable var cornerRadius: CGFloat = 0

    var isRoundTopCorner: Bool = false {
        didSet {
            drawCornerRadius()
        }
    }

    var isRoundBottomCorner: Bool = false {
        didSet {
            drawCornerRadius()
        }
    }

    func drawCornerRadius() {
        if isRoundTopCorner || isRoundBottomCorner {
            let rcfirst: UIRectCorner = isRoundTopCorner ? [UIRectCorner.topLeft, UIRectCorner.topRight] : []
            let rclast:  UIRectCorner = isRoundBottomCorner  ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight] : []
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        }
    }

}
