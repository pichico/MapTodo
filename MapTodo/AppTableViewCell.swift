//
//  AppTableViewCell.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/05/15.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {
    @IBInspectable var tableBorderColor: UIColor = UIColor.black
    @IBInspectable var tableBorderWidth: CGFloat = 1
    @IBInspectable var tableCornerRadius: CGFloat = 0

    var isTop: Bool = false {
        didSet {
            updateBorder()
        }
    }
    var isBottom: Bool = false {
        didSet {
            updateBorder()
        }
    }
    var borderLayer: CAShapeLayer = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }

    func updateBorder() {
        let rcfirst: UIRectCorner = isTop ? [UIRectCorner.topLeft, UIRectCorner.topRight] : []
        let rclast:  UIRectCorner = isBottom  ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight] : []

        // 角丸
        if (isTop || isBottom) && tableCornerRadius > 0 {
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: tableCornerRadius, height: tableCornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }

        // 境界線 + 枠をつける。 上下のcellで二重に線が描画されるので、下のcellの上の辺を上のcellの下の辺に重ねる
        let borderBounds = isTop ? bounds : CGRect(x: bounds.origin.x, y: bounds.origin.y - tableBorderWidth, width: bounds.width, height: bounds.height + tableBorderWidth)
        let borderPath = UIBezierPath(roundedRect: borderBounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: tableCornerRadius, height: tableCornerRadius))
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = tableBorderColor.cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = tableBorderWidth
        if borderLayer.superlayer == nil {
            layer.addSublayer(borderLayer)
        }
    }

}
