//
//  PlaceViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/10.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit
import UIKit


class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    var place: Place? = nil
    var mapPoint: CLLocationCoordinate2D? = nil
    var todoEntities: [Todo] = []
    var lm: CLLocationManager! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if place != nil {
            if place!.latitude != nil &&  place!.longitude != nil {
                mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(
                    place!.latitude as! CLLocationDegrees, place!.longitude as! CLLocationDegrees),
                    MKCoordinateSpanMake(0.005, 0.005)),
                    animated:true)
            }
            placeNameTextField.text = place?.name
            let predicate: NSPredicate = NSPredicate(format: "place = %@", argumentArray: [place!])
            todoEntities = Todo.mr_findAll(with: predicate) as! [Todo]
        } else {
            lm = CLLocationManager()
            lm.delegate = self
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 300
            lm.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }

        // 既にあるpinを消す
        self.mapView.removeAnnotations(self.mapView.annotations)

        //senderから長押しした地図上の座標を取得
        let tappedLocation = sender.location(in: mapView)
        mapPoint = mapView.convert(tappedLocation, toCoordinateFrom: mapView)

        //ピンの生成
        let pin = MKPointAnnotation()
        //ピンを置く場所を指定
        pin.coordinate = mapPoint!
        print(mapPoint?.latitude)
        print(mapPoint?.longitude)
        //ピンをMapViewの上に置く
        self.mapView.addAnnotation(pin)
    }

    func replacePlace() {
        if place == nil {
            place = Place.mr_createEntity()!
        }
        place?.name = placeNameTextField.text
        if mapPoint != nil {
            place?.latitude = mapPoint!.latitude as NSNumber?
            place?.longitude = mapPoint!.longitude as NSNumber?
            // TODO radius指定できるようにする
            lm.startMonitoring(for: CLCircularRegion.init(center: mapPoint!, radius: 200, identifier: place!.name!))
        }
        
        place?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    @IBAction func save(_ sender: AnyObject) {
        if mapPoint == nil {
            let alert: UIAlertController = UIAlertController(title: "場所の指定がされていません", message: "近くに来たときに通知するには、地図を長押しして地点を指定して下さい", preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "場所を指定せずに保存", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                self.replacePlace()
                self.navigationController!.popViewController(animated: true)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "場所を指定する", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        } else {
            replacePlace()
            navigationController!.popViewController(animated: true)
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
}

extension PlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoEntities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TodoListItem")
        cell.textLabel?.text = todoEntities[indexPath.row].item
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todoEntities.remove(at: indexPath.row).mr_deleteEntity()
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            tableView.reloadData()
        }
    }

}

extension PlaceViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mapView.setRegion(MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude),
                                       MKCoordinateSpanMake(0.005, 0.005)), animated:true)
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("start" + region.identifier)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("enter region" + region.identifier)
        let alert: UIAlertController = UIAlertController(title: "到着", message: region.identifier as String + "に到着", preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)

    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit region" + region.identifier)
        let alert: UIAlertController = UIAlertController(title: "出発", message: region.identifier as String + "を出発", preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}
