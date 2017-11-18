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

    static func getAll(realm: Realm) -> Results<Todo> {
        return realm.objects(self)
    }

    static func getList(realm: Realm, place: Place) -> Results<Todo> {
        return realm.objects(self).filter(NSPredicate(format: "place = %@", place))
    }

    public func delete(realm: Realm) {
        realm.delete(self)
    }

    public func replace(realm: Realm, item: String!, place: Place!) {
        self.item = item
        self.place = place
        realm.add(self, update: true)
    }
}
