//
//  PlaceViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/10.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import GoogleMaps
import Instructions
import RealmSwift
import UIKit

class PlaceViewController: AppViewController {
    @IBOutlet weak var radiusStepper: UIStepper!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapViewFrame: UIView!
    @IBOutlet weak var mapViewCoachMarkGuide: UIView!
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var footerView: UIView!

    let defaultZoom: Float = 15.0
    var gmView: GMSMapView!
    let lm: LocationManager = LocationManager.sharedLocationManager
    let lmmap: CLLocationManager = CLLocationManager()
    var mapPoint: CLLocationCoordinate2D? = nil
    var place: Place!
    var isNew: Bool!
    let realm: Realm = try! Realm()
    var todoEntiries: Results<Todo>!

    let coachMarksController = CoachMarksController()

    override func viewDidLoad() {
        super.viewDidLoad()
        if place == nil {
            if Place.getAll(realm: realm).count == 0 {
                coachMarksController.dataSource = self
                coachMarksController.overlay.color = UIColor(white: 0.5, alpha: 0.5)
                coachMarksController.start(on: self)
            }
            place = Place()
            isNew = true
        } else {
            isNew = false
        }

        // map
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: defaultZoom)
        gmView = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        gmView.isMyLocationEnabled = true
        gmView.settings.zoomGestures = true
        gmView.settings.scrollGestures = true
        gmView.delegate = self
        mapView.addSubview(gmView)

        lmmap.delegate = self

        updateValues()
        if let tableHeaderView = todoListTableView.tableHeaderView {
            var frame = todoListTableView.frame
            frame.size.height = 450
            tableHeaderView.frame = frame
            todoListTableView.tableHeaderView = tableHeaderView
        }
    }

    func updateValues() {
        footerView.isHidden = isNew
        if let place = place {
            navigationItem.title = place.name
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

    func replacePlace(name: String) {
        try! realm.write {
            place.stopMonitoring()
            place.replace(realm: realm, name: name, radius: radiusStepper.value, point: mapPoint)
            place.startMonitoring()
        }
        UIApplication.shared.cancelAllLocalNotifications()
    }

    func deletePlace() {
        try! realm.write {
            todoEntiries.forEach { $0.delete(realm: self.realm) }
            place.delete(realm: realm)
        }
        navigationController!.popViewController(animated: true)
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

    func showSaveDialog() {
        let alert: UIAlertController = UIAlertController(
            title: "場所を保存します",
            message: "この場所の呼び名を入力してください",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "登録", style: UIAlertActionStyle.default) { _ in
            // 入力したテキストをコンソールに表示
            if let name = (alert.textFields![0] as UITextField).text, name != "" {
                self.replacePlace(name: name)
                self.navigationController!.popViewController(animated: true)
            } else {
                self.showSaveDialog()
            }
        })
        alert.addTextField(configurationHandler: { (text: UITextField!) in
            text.text = self.place.name
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func deletePlaceButtonClicked(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(
            title: "この場所を削除しますか？",
            message: "登録されているToDoも削除されます。",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
        alert.addAction(UIAlertAction(title: "削除する", style: UIAlertActionStyle.default) { _ in
            self.deletePlace()
            self.navigationController!.popViewController(animated: true)
        })
        present(alert, animated: true, completion: nil)
    }

    @IBAction func radiusStepperTapped(_ sender: UIStepper) {
        if mapPoint != nil {
            showMonitoringRegion(mapPoint, radius: sender.value)
        }
    }

    @IBAction func save(_ sender: AnyObject) {
        if mapPoint == nil {
            let alert: UIAlertController = UIAlertController(title: "場所の指定がされていません", message: "近くに来たときに通知するには、地図を長押しして地点を指定して下さい", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "場所を指定せずに保存", style: UIAlertActionStyle.default) { _ in
                self.showSaveDialog()
            })
            alert.addAction(UIAlertAction(title: "場所を指定する", style: UIAlertActionStyle.cancel))

            present(alert, animated: true, completion: nil)
        } else {
            showSaveDialog()
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
        cell.isTop = indexPath.row == 0
        if todoEntiries.count > indexPath.row {
            cell.textField.text = todoEntiries[indexPath.row].item
            cell.isBottom = false
        } else {
            cell.textField.text = ""
            cell.isBottom = true
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
        let isNew: Bool
        if indexPath.row < todoEntiries.count {
            todo = todoEntiries[indexPath.row]
            isNew = false
        } else if !value.isEmpty {
            todo = Todo()
            isNew = true
        } else {
            return
        }

        if value != todo.item {
            try! realm.write {
                todo.replace(realm: realm, item: value, place: place)
            }
            todoListTableView.reloadData()
            // 追加した場合、次の空白行にフォーカスをあててキーボードを出す
            if isNew {
                if let cell = todoListTableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) as? TextFieldTableViewCell {
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }
}

extension PlaceViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return coachMarkConfigs.count
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: coachMarkConfigs[index].view)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark)
        -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
            let config = coachMarkConfigs[index]
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(
                withArrow: true,
                arrowOrientation: coachMark.arrowOrientation
            )
            coachViews.bodyView.hintLabel.text = config.text
            coachViews.bodyView.nextLabel.text = "OK"
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }

    var coachMarkConfigs: [(view: UIView, text: String)] {
        return [
            (view: mapViewCoachMarkGuide, text: "①地図上でタスクを登録したい場所を長押しし、ピンを立てます"),
            (view: radiusStepper, text: "②タスクをリマインドしたい範囲をこのボタンで調整し、「Save」ボタンを押します")
        ]
    }
}
