//
//  AppTableViewCell.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/05/15.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {

    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderWidth: CGFloat = 1
    var isTop: Bool = false
    var isBottom: Bool = false
    var borderLayer: CAShapeLayer = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }

    func updateBorder() {
        let rcfirst: UIRectCorner = isTop ? [UIRectCorner.topLeft, UIRectCorner.topRight] : []
        let rclast:  UIRectCorner = isBottom  ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight] : []

        // 角丸
        if (isTop || isBottom) && cornerRadius > 0 {
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        }

        // 境界線 + 枠をつける。 上下のcellで二重に線が描画されるので、下のcellの上の辺を上のcellの下の辺に重ねる
        let borderBounds = isTop ? bounds : CGRect(x: bounds.origin.x, y: bounds.origin.y - borderWidth, width: bounds.width, height: bounds.height + borderWidth)
        let borderPath = UIBezierPath(roundedRect: borderBounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        borderLayer.removeFromSuperlayer() // これしておかないと大きい画面のときとかに線が複数描画される
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = borderWidth
        layer.addSublayer(borderLayer)
    }
}
