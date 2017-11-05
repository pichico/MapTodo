//
//  AppTableViewHeaderView.swift
//  MapTodo
//
//  Created by 福島瞳美 on 2017/11/04.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppTableViewHeaderView: UIView {
    var cornerRadius: CGFloat = 5
    var borderWidth: CGFloat = 2
    var borderColor: UIColor = UIColor.init(red: 0.62745098039215685, green: 0.63529411764705879, blue: 0.63921568627450975, alpha: 1)

    @IBOutlet var backgroundView: UIView!
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
        view.frame = CGRect.init(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.addSubview(view)
    }

    func updateBorder() {
        let rcfirst: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]

        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: rcfirst, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer

        // 枠をつける。
        let borderLayer: CAShapeLayer = CAShapeLayer()
        let borderBounds = bounds
        let borderPath = UIBezierPath(roundedRect: borderBounds, byRoundingCorners: [rcfirst], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = borderWidth
        layer.addSublayer(borderLayer)
    }

    func setLabelText(text: String?) {
        textLabel.text = text
    }

}
