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
    var latitude: Double? = nil
    var longitude: Double? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if place != nil {
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(place!.latitude, place!.longitude),
                                                     MKCoordinateSpanMake(0.005, 0.005)),
                              animated:true)
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
        latitude = Double(tappedPoint.latitude)
        longitude = Double(tappedPoint.longitude)

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
        newPlace.latitude = latitude!
        newPlace.longitude = longitude!
        newPlace.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    func editTask() {
        place?.name = placeNameTextField.text
        place?.latitude = latitude!
        place?.longitude = longitude!
        place?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    @IBAction func save(_ sender: AnyObject) {
        if place == nil {
            createPlace()
        } else {
            editTask()
        }
        navigationController!.popViewController(animated: true)
    }

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
}
