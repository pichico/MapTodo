//
//  TodoListItemTableViewCell.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/09.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit



protocol TodoListItemTableViewCellDelegate {
    func textFieldDidEndEditing(cell: TodoListItemTableViewCell, value: NSString) -> ()
}

class TodoListItemTableViewCell: UITableViewCell, UITextFieldDelegate {
    var delegate: TodoListItemTableViewCellDelegate! = nil

    @IBOutlet weak var todoTextField: UITextField!


    override func awakeFromNib() {
        super.awakeFromNib()
        todoTextField.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    internal func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate.textFieldDidEndEditing(cell: self, value: (textField.text as NSString!))
    }

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


