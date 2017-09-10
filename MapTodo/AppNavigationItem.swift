//
//  AppNavigationItem.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/06/11.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import UIKit

class AppNavigationItem: UINavigationItem {
    @IBInspectable var iconImage: UIImage? = nil
    @IBInspectable var titleColor: UIColor? = UIColor.white
    override func awakeFromNib() {
        super.awakeFromNib()
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.textColor = titleColor
        if iconImage != nil {
            let iconView = UIImageView(image: iconImage)
            let iconMargin: CGFloat = 10
            titleLabel.frame = CGRect(x: iconView.frame.width + iconMargin, y: 0.5 * (iconView.frame.height - titleLabel.frame.height), width: titleLabel.frame.width, height: titleLabel.frame.height)
            let unionView = UIView(frame: CGRect(x: 0, y: 0, width: iconView.frame.width + titleLabel.frame.width, height: max(iconView.frame.height, titleLabel.frame.height)))
            unionView.addSubview(iconView)
            unionView.addSubview(titleLabel)
            titleView = unionView
        } else {
            titleView = titleLabel
        }
    }
}
