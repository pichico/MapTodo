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
        return MapTodoRealm.sharedRealm.realm.objects(Todo.self)
    }


    static func get(place: Place) -> Results<Todo> {
        return MapTodoRealm.sharedRealm.realm.objects(Todo.self).filter(NSPredicate(format: "place = %@", argumentArray: [place]))
    }

    public func delete() {
        let realm = MapTodoRealm.sharedRealm.realm
        try! MapTodoRealm.sharedRealm.realm.write {
            realm.delete(self)
        }
    }

    public func replace(item: String!, place: Place!) {
        self.item = item
        self.place = place
        MapTodoRealm.sharedRealm.realm.add(self, update: true)
    }
}
