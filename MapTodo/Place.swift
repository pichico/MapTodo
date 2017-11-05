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
        return try! Realm().objects(self)
    }

    public static func get(uiid: String) -> Place? {
        return try! Realm().object(ofType: self, forPrimaryKey: uiid)
    }

    public func delete() {
        try! Realm().delete(self)
    }

    public func replace(name: String, radius: Double?, point: CLLocationCoordinate2D?) {
        self.name = name
        if let point = point { // 新しいMonitoringを開始
            let radius = radius!
            self.radius.value = radius
            self.latitude.value = point.latitude
            self.longitude.value = point.longitude
        }
       try! Realm().add(self, update: true)
    }
}

extension Place {

    var CLLocationCoordinate2D: CLLocationCoordinate2D? {
        get {
            if let latitude = latitude.value, let longitude = longitude.value {
                return CLLocationCoordinate2DMake(latitude , longitude)
            } else {
                return nil
            }
        }
        set(CLLocationCoordinate2D) {
            latitude.value = CLLocationCoordinate2D?.latitude
            longitude.value = CLLocationCoordinate2D?.longitude
        }
    }

    func startMonitoring() {
        let lm = LocationManager.sharedLocationManager
        if let CLLocationCoordinate2D = CLLocationCoordinate2D {
            lm.startMonitoring(CLLocationCoordinate2D, radius: self.radius.value!, identifier: self.uuid)
        }
    }

    func stopMonitoring() {
        let lm = LocationManager.sharedLocationManager
        if let CLLocationCoordinate2D = CLLocationCoordinate2D {
            lm.stopMonitoring(CLLocationCoordinate2D, radius: self.radius.value!, identifier: self.uuid)
        }
    }

}
