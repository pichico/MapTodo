//
//  Place.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2017/02/19.
//  Copyright © 2017年 fukushima. All rights reserved.
//

import CoreLocation
import Foundation
import RealmSwift

class Place: Object {

    var latitude = RealmOptional<Double>(nil)
    var longitude = RealmOptional<Double>(nil)
    dynamic var name: String? = nil
    dynamic var uuid = UUID().uuidString
    var radius = RealmOptional<Double>(nil)

    override static func primaryKey() -> String? {
        return "uuid"
    }

    public static func getAll() -> Results<Place> {
        return MapTodoRealm.sharedRealm.realm.objects(Place.self)
    }

    public static func get(uiid: String) -> Place? {
        return getAll().filter(NSPredicate(format: "uuid = %@", argumentArray: [uiid])).first
    }

    public func delete() {
        if self.latitude.value != nil {
            LocationManager.sharedLocationManager.stopMonitoring(CLLocationCoordinate2DMake(
                self.latitude.value! as CLLocationDegrees, self.longitude.value! as CLLocationDegrees), radius: self.radius.value! as CLLocationDistance, identifier: self.uuid)
        }
        let realm = MapTodoRealm.sharedRealm.realm
        try! realm.write {
            realm.delete(self)
        }
    }

    public func replace(name: String, radius: Double?, point: CLLocationCoordinate2D?) {
        let lm = LocationManager.sharedLocationManager
        if self.latitude.value != nil { // 古いMonitoringを消す
            lm.stopMonitoring(CLLocationCoordinate2DMake(
                self.latitude.value! , self.longitude.value! ), radius: self.radius.value!, identifier: self.uuid)
        }
        self.name = name
        if let point = point { // 新しいMonitoringを開始
            let radius = radius!
            self.radius.value = radius
            self.latitude.value = point.latitude
            self.longitude.value = point.longitude
            lm.startMonitoring(point, radius: radius, identifier: self.uuid)
        }
        MapTodoRealm.sharedRealm.realm.add(self, update: true)
    }
}
