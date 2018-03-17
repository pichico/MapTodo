//
//  Todo.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/02/19.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift

class Todo: Object {
    @objc dynamic var item: String?
    @objc dynamic var place: Place? = nil
    @objc dynamic var uuid = UUID().uuidString

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

        Analytics.logEvent("delete_todo", parameters: [
            "uuid": uuid as NSObject,
            "place": place!.uuid as NSObject
            ])
    }

    public func replace(realm: Realm, item: String, place: Place!) {
        self.item = item
        self.place = place
        realm.add(self, update: true)

        Analytics.logEvent("replace_todo", parameters: [
            "uuid": uuid as NSObject,
            "place": place.uuid as NSObject
            ])
    }
}
