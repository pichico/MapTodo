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

    var place : Place? = nil
    @IBOutlet weak var placeNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(_ sender: AnyObject) {
        createPlace()
        navigationController!.popViewController(animated: true)
    }

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

    func createPlace() {
        let newPlace: Place = Place.mr_createEntity()!
        newPlace.name = placeNameTextField.text
        newPlace.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }
}
