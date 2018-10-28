//
//  AppUILabel.swift
//  MapTodo
//
//  Created by 福島瞳美 on 2018/10/28.
//  Copyright © 2018年 fukushima. All rights reserved.
//

import UIKit
class AppUILabel: UILabel {
    @IBInspectable var padding: CGFloat = 0

    override func drawText(in rect: CGRect) {
         let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
