//
//  TextFieldTableViewCell.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/09.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    func textFieldDidEndEditing(cell: TextFieldTableViewCell, value: String, indexPath: IndexPath)
    func textFieldDidBeginEditing(cell: TextFieldTableViewCell)
}

class TextFieldTableViewCell: AppTableViewCell, UITextFieldDelegate {
    weak var delegate: TextFieldTableViewCellDelegate!
    var indexPath: IndexPath?
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        if let view = Bundle.main.loadNibNamed("TextFieldTableViewCell", owner: self, options: nil)?.first as? UIView {
            view.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            textField.delegate = self
            textField.returnKeyType = .done
            self.addSubview(view)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    internal func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate.textFieldDidEndEditing(cell: self, value: textField.text!, indexPath: self.indexPath!)
    }

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate.textFieldDidBeginEditing(cell: self)
    }
}
