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
    dynamic var uuid = UUID().uuidString

    override static func primaryKey() -> String? {
        return "uuid"
    }

    static func getAll() -> Results<Todo> {
        return try! Realm().objects(self)
    }

    static func getList(place: Place) -> Results<Todo> {
        return try! Realm().objects(self).filter(NSPredicate(format: "place = %@", place))
    }

    public func delete() {
        try! Realm().delete(self)
    }

    public func replace(item: String!, place: Place!) {
        self.item = item
        self.place = place
        try! Realm().add(self, update: true)
    }
}
