//
//  RealmManager.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/02/25.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import Foundation
import RealmSwift

final class MapTodoRealm: NSObject {
    static let sharedRealm = MapTodoRealm()
    public var realm: Realm = try! Realm()

    fileprivate override init() {
        super.init()
    }
}


