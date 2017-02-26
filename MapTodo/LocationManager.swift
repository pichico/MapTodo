//
//  LocationManager.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/11/26.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit
import RealmSwift


final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedLocationManager = LocationManager()
    fileprivate let lm: CLLocationManager = CLLocationManager()
    fileprivate override init() {
        super.init()
        lm.delegate = self
        lm.requestAlwaysAuthorization()

        lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation //測定の制度を設定
        lm.pausesLocationUpdatesAutomatically=false //位置情報が自動的にOFFにならない様に設定
        lm.distanceFilter=100.0// 100m以上移動した場合に位置情報を取得

    }
    
    func startMonitoring(_ center: CLLocationCoordinate2D, radius: Double, identifier: String) {
        lm.startMonitoring(for: CLCircularRegion.init(center: center, radius: radius, identifier: identifier))
    }

    func stopMonitoring(_ center: CLLocationCoordinate2D, radius: Double, identifier: String) {
        lm.stopMonitoring(for: CLCircularRegion.init(center: center, radius: radius, identifier: identifier))
    }
    
    func monitoredRegionsCount() -> Int {
        return lm.monitoredRegions.count
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let place = Place.get(uiid: region.identifier){
            if Todo.get(place: place).count > 0 {
                let notification = UILocalNotification()
                notification.alertBody = place.name! + "に到着"
                notification.userInfo = ["region":region.identifier]
                notification.applicationIconBadgeNumber = 1
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
}

