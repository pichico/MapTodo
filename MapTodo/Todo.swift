//
//  Todo.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/02/19.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    dynamic var item: String?
    dynamic var place: Place? = nil
    dynamic var uuid = ""

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
