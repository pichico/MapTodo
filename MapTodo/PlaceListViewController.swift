//
//  PlaceListViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/16.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit
import CoreData

class PlaceListViewController: UIViewController {

    @IBOutlet weak var placeListTableView: UITableView!
    var placeEntities: [Place]!

    override func viewDidLoad() {
        super.viewDidLoad()
        placeEntities = Place.mr_findAll() as! [Place]!
        placeListTableView.delegate = self
        placeListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        placeEntities = Place.mr_findAll() as! [Place]!
        placeListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            placeEntities.remove(at: indexPath.row).mr_deleteEntity()
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            placeListTableView.reloadData()
        }
    }
}
