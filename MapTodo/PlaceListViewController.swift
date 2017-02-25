//
//  PlaceListViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/16.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreLocation
import RealmSwift
import UIKit

class PlaceListViewController: UIViewController {

    @IBOutlet weak var placeListTableView: UITableView!

    var placeEntities: Results<Place>!
    let lm: LocationManager = LocationManager.sharedLocationManager
    var realm: Realm! = MapTodoRealm.sharedRealm.realm

    override func viewDidLoad() {
        super.viewDidLoad()
        placeEntities = realm.objects(Place.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        placeEntities = realm.objects(Place.self)
        placeListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let placeViewController = segue.destination as! PlaceViewController
            placeViewController.place = placeEntities[placeListTableView.indexPathForSelectedRow!.row]
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeEntities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "PlaceListItem")
        cell.textLabel?.text = placeEntities[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = placeEntities[indexPath.row]
            if place.latitude.value != nil {
                lm.stopMonitoring(CLLocationCoordinate2DMake(
                    place.latitude.value! as CLLocationDegrees, place.longitude.value! as CLLocationDegrees), radius: place.radius.value! as CLLocationDistance, identifier: place.uuid)
            }
            try! realm.write {
                realm.delete(place)
            }
            placeListTableView.reloadData()
        }
    }
}
