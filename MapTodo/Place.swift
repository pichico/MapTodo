//
//  PlaceRealm.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/02/19.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import Foundation
import RealmSwift

class Place: Object {

    var latitude = RealmOptional<Double>(nil)
    var longitude = RealmOptional<Double>(nil)
    dynamic var name: String? = nil
    dynamic var uuid = ""
    var radius = RealmOptional<Double>(nil)

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
