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
    @IBInspectable var showDetailButtonImage: UIImage? = nil

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
        if (isTop || isBottom) && cornerRadius > 0 {
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }

        // 境界線 + 枠をつける。 上下のcellで二重に線が描画されるので、下のcellの上の辺を上のcellの下の辺に重ねる
        let borderBounds = isTop ? bounds : CGRect(x: bounds.origin.x, y: bounds.origin.y - borderWidth, width: bounds.width, height: bounds.height + borderWidth)
        let borderPath = UIBezierPath(roundedRect: borderBounds, byRoundingCorners: [rcfirst, rclast], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = borderWidth
        if borderLayer.superlayer == nil {
            layer.addSublayer(borderLayer)
        }
    }

    //showDetailButtonImage がある前提なので、ないのに呼び出すとエラーになる
    func initializeShowDetailButton() -> UIButton {
        let showDetailButton: UIButton = UIButton()
        showDetailButton.setImage(showDetailButtonImage!, for: UIControlState.normal)
        let margin: CGFloat = 5
        showDetailButton.frame = CGRect(x: self.bounds.width - self.bounds.height + margin, y: margin , width: self.bounds.height - 2 * margin, height: self.bounds.height - 2 * margin)
        addSubview(showDetailButton)
        textLabel?.frame.size.width = (textLabel?.frame.width)! - (margin + showDetailButton.bounds.width)
        return showDetailButton
    }
}
