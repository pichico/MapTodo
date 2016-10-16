//
//  PlaceViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/10.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit
import CoreData

class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameTextField: UITextField!

    var place : Place? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if place != nil {
            placeNameTextField.text = place?.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createPlace() {
        let newPlace: Place = Place.mr_createEntity()!
        newPlace.name = placeNameTextField.text
        newPlace.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }

    func editTask() {
        place?.name = placeNameTextField.text
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
