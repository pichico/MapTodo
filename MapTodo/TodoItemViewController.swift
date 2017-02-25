//
//  TodoItemViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/09.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreData
import RealmSwift
import UIKit

class TodoItemViewController: UIViewController {

    @IBOutlet weak var todoField: UITextField!
    @IBOutlet weak var placePickerView: UIPickerView!

    var task: Todo? = nil
    var places: Results<Place>!
    var realm: Realm!

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        places = realm.objects(Place.self)
        if let taskTodo = task {
            todoField.text = taskTodo.item
            if let place = taskTodo.place, let index = places.index(of: place) {
                placePickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    // いる？
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        placePickerView.reloadAllComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if task == nil {
            task = Todo()
            task!.uuid = UUID().uuidString
        }
        realm.beginWrite()
        task!.item = todoField.text
        task!.place = places[placePickerView.selectedRow(inComponent: 0)]
        realm.add(task!, update: true)
        try! realm.commitWrite()

        navigationController!.popViewController(animated: true)
    }

}

extension TodoItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return places.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return places[row].name
    }
}
