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
    @IBOutlet weak var radiusStepper: UIStepper!
    @IBOutlet weak var mapView: MKMapView!
    
    let lm: LocationManager = LocationManager.sharedLocationManager
    let lmmap: CLLocationManager = CLLocationManager()
    var mapPoint: CLLocationCoordinate2D? = nil
    var place: Place? = nil
    var todoEntities: [Todo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        lmmap.delegate = self
        mapView.showsUserLocation=true //地図上に現在地を表示
        if let place = place {
            if place.latitude != nil &&  place.longitude != nil {
                mapPoint = CLLocationCoordinate2DMake(
                    place.latitude as! CLLocationDegrees, place.longitude as! CLLocationDegrees)
                mapView.setRegion(MKCoordinateRegionMake(mapPoint!, MKCoordinateSpanMake(0.005, 0.005)), animated:false)
                radiusStepper.value = place.radius as! Double
                showMonitoringRegion(center: mapPoint, radius: radiusStepper.value)
            }
            placeNameTextField.text = place.name
            let predicate: NSPredicate = NSPredicate(format: "place = %@", argumentArray: [place])
            todoEntities = Todo.mr_findAll(with: predicate) as! [Todo]
        }
        if place == nil || place!.latitude == nil {
            //デフォルトのmap
            lmmap.desiredAccuracy = kCLLocationAccuracyBest
            lmmap.distanceFilter = 200
            lmmap.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func replacePlace() {
        if place == nil {
            place = Place.mr_createEntity()!
            place!.uuid = NSUUID().uuidString
        } else {
            if place!.latitude != nil {
                lm.stopMonitoring(center: CLLocationCoordinate2DMake(
                    place!.latitude as! CLLocationDegrees, place!.longitude as! CLLocationDegrees), radius: place!.radius as! CLLocationDistance, identifier: place!.uuid!)
            }
        }
        place!.name = placeNameTextField.text
        if mapPoint != nil {
            place!.radius = radiusStepper.value as NSNumber
            place!.latitude = mapPoint!.latitude as NSNumber?
            place!.longitude = mapPoint!.longitude as NSNumber?
            lm.startMonitoring(center: mapPoint!, radius: radiusStepper.value, identifier: place!.uuid!)
        }
        place?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    func showMonitoringRegion(center: CLLocationCoordinate2D!, radius: CLLocationDistance) {
        // 既にあるpin、円を消す
        mapView.removeAnnotations(self.mapView.annotations)
        for id in mapView.overlays {
            mapView.remove(id)
        }
        
        //ピンをMapViewの上に置く
        let pin = MKPointAnnotation()
        pin.coordinate = center!
        mapView.addAnnotation(pin)
        
        //ジオフェンスの範囲表示用
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(center!.latitude, center!.longitude)
        let circle:MKCircle = MKCircle(center:center , radius: radius)
        mapView.add(circle)
    }
    
    @IBAction func radiusStepperTapped(_ sender: UIStepper) {
        if mapPoint != nil {
            showMonitoringRegion(center: mapPoint, radius: sender.value)
        }
    }
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        if place == nil && lm.monitoredRegionsCount() >= 20 {
            let alert: UIAlertController = UIAlertController(title: "登録できる地点は20個までです。", message: "どれかを消して下さい。", preferredStyle:  UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "一覧に戻る", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                self.navigationController!.popViewController(animated: true)
            })
            alert.addAction(cancelAction)
            let mapResetAction: UIAlertAction = UIAlertAction(title: "地点を保存しない", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(mapResetAction)
            present(alert, animated: true, completion: nil)
        } else {
            let tappedLocation = sender.location(in: mapView)
            mapPoint = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            showMonitoringRegion(center: mapPoint, radius: radiusStepper.value)
        }
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if placeNameTextField.text == "" {
            let alert: UIAlertController = UIAlertController(title: "名前を設定して下さい", message: "", preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        } else if mapPoint == nil {
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
            MKCoordinateSpanMake(0.005, 0.005)), animated:false)
    }
}

extension PlaceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render:MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        render.strokeColor = UIColor.red
        render.fillColor = UIColor.red.withAlphaComponent(0.4)
        render.lineWidth=1
        return render
    }
}
