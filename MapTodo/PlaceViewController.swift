//
//  PlaceViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/10.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import GoogleMaps
import RealmSwift
import UIKit

class PlaceViewController: AppViewController {
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var radiusStepper: UIStepper!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var todoListTableView: UITableView!

    let defaultZoom: Float = 15.0
    var gmView: GMSMapView!
    let lm: LocationManager = LocationManager.sharedLocationManager
    let lmmap: CLLocationManager = CLLocationManager()
    var mapPoint: CLLocationCoordinate2D? = nil
    var place: Place!
    let realm: Realm = try! Realm()
    var todoEntiries: Results<Todo>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // map
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: defaultZoom)
        gmView = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        gmView.isMyLocationEnabled = true
        gmView.settings.zoomGestures = true
        gmView.settings.scrollGestures = true
        gmView.delegate = self
        mapView.addSubview(gmView)

        lmmap.delegate = self

        placeNameTextField.returnKeyType = .done
        place = place ?? Place()
        updateValues()
    }

    func updateValues() {
        if let place = place {
            placeNameTextField.text = place.name
            if let CLLocationCoordinate2D = place.CLLocationCoordinate2D { // 地図をあわせる
                mapPoint = CLLocationCoordinate2D
                let camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D, zoom: defaultZoom)
                gmView.moveCamera(GMSCameraUpdate.setCamera(camera))
                radiusStepper.value = place.radius.value!
                showMonitoringRegion(mapPoint, radius: radiusStepper.value)
            } else {
                //デフォルトのmap
                lmmap.desiredAccuracy = kCLLocationAccuracyBest
                lmmap.distanceFilter = 200
                lmmap.startUpdatingLocation()
            }
            todoEntiries = Todo.getList(realm: realm, place: place)
        }
    }

    func replacePlace() {
        try! realm.write {
            place.stopMonitoring()
            place.replace(realm: realm, name: placeNameTextField.text!, radius: radiusStepper.value, point: mapPoint)
            place.startMonitoring()
        }
        UIApplication.shared.cancelAllLocalNotifications()
    }

    func showMonitoringRegion(_ center: CLLocationCoordinate2D!, radius: CLLocationDistance) {
        // 既にあるpin、円を消す
        gmView.clear()

        //ピンをMapViewの上に置く
        let marker = GMSMarker(position: center)
        marker.map = gmView

        //ジオフェンスの範囲表示用
        let circle = GMSCircle(position: center, radius: radius)
        circle.strokeColor = UIColor(red: 160 / 255.0, green: 162 / 255.0, blue: 163 / 255.0, alpha: 1)
        circle.map = gmView
    }

    @IBAction func radiusStepperTapped(_ sender: UIStepper) {
        if mapPoint != nil {
            showMonitoringRegion(mapPoint, radius: sender.value)
        }
    }

    @IBAction func save(_ sender: AnyObject) {
        if placeNameTextField.text == "" {
            let alert: UIAlertController = UIAlertController(
                title: "名前を設定して下さい",
                message: "",
                preferredStyle: UIAlertControllerStyle.alert
            )
            let defaultAction: UIAlertAction = UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.cancel,
                    handler: {
                        (action: UIAlertAction!) -> Void in
                    }
            )
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
        return todoEntiries.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TodoListItem") as? TextFieldTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        if todoEntiries.count > indexPath.row {
            cell.textField.text = todoEntiries[indexPath.row].item
        } else {
            cell.textField.text = ""
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if todoEntiries.count > indexPath.row {
                try! realm.write {
                    realm.delete(todoEntiries[indexPath.row])
                }
                updateValues()
                todoListTableView.reloadData()
            }
        }
    }
}

extension PlaceViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if place.CLLocationCoordinate2D == nil && lm.monitoredRegionsCount() >= 20 {
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
            mapPoint = coordinate
            showMonitoringRegion(coordinate, radius: radiusStepper.value)
        }
    }
}

extension PlaceViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera = GMSCameraPosition.camera(withTarget: locations[0].coordinate, zoom: defaultZoom)
        gmView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }
}

extension PlaceViewController: TextFieldTableViewCellDelegate {
    func textFieldDidEndEditing(cell: TextFieldTableViewCell, value: String, indexPath: IndexPath) {
        let todo: Todo
        if indexPath.row < todoEntiries.count {
            todo = todoEntiries[indexPath.row]
        } else if !value.isEmpty {
            todo = Todo()
        } else {
            return
        }
        if value != todo.item {
            try! realm.write {
                todo.replace(realm: realm, item: value, place: place)
            }
            todoListTableView.reloadData()
        }
    }
}
