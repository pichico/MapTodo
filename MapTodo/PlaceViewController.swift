//
//  PlaceViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/10.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    var place: Place? = nil
    var latitude: NSNumber? = nil
    var longitude: NSNumber? = nil

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
        } else {
            // TODO それっぽい場所に移動
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(35.6581, 139.701742),
                                                 MKCoordinateSpanMake(0.005, 0.005)),
                                                animated:true)
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
        let tappedPoint = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
        latitude = tappedPoint.latitude as NSNumber?
        longitude = tappedPoint.longitude as NSNumber?

        //ピンの生成
        let pin = MKPointAnnotation()
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンをMapViewの上に置く
        self.mapView.addAnnotation(pin)
    }

    func createPlace() {
        let newPlace: Place = Place.mr_createEntity()!
        newPlace.name = placeNameTextField.text
        newPlace.latitude = latitude
        newPlace.longitude = longitude
        newPlace.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    func editTask() {
        place?.name = placeNameTextField.text
        place?.latitude = latitude
        place?.longitude = longitude
        place?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    func replacePlace() {
        if place == nil {
            place = Place.mr_createEntity()!
        }
        place?.name = placeNameTextField.text
        place?.latitude = latitude
        place?.longitude = longitude
        place?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    @IBAction func save(_ sender: AnyObject) {
        if latitude == nil {
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
