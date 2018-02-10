//
//  AppTableViewHeaderView.swift
//  MapTodo
//
//  Created by 福島瞳美 on 2017/11/04.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppTableViewHeaderView: UIView {
    let tableCornerRadius = CGFloat(5)
    let tableBorderWidth = CGFloat(2)
    let tableBorderColor = UIColor(red: 160 / 255.0, green: 162 / 255.0, blue: 163 / 255.0, alpha: 1)

    @IBOutlet weak var showDetailButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateBorder()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib() {
        let view = R.nib.appTableViewHeaderView.firstView(owner: self)!
        view.frame = bounds
        self.addSubview(view)
    }

    func updateBorder() {
        let rcfirst: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]

        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: rcfirst, cornerRadii: CGSize(width: tableCornerRadius, height: tableCornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer

        // 枠をつける。
        let borderLayer: CAShapeLayer = CAShapeLayer()
        let borderBounds = bounds
        let borderPath = UIBezierPath(roundedRect: borderBounds, byRoundingCorners: [rcfirst], cornerRadii: CGSize(width: tableCornerRadius, height: tableCornerRadius))
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = tableBorderColor.cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = tableBorderWidth
        layer.addSublayer(borderLayer)
    }

    func setLabelText(text: String?) {
        textLabel.text = text
    }

}
