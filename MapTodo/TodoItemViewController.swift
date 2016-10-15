//
//  TodoItemViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/09.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import UIKit
import CoreData

class TodoItemViewController: UIViewController {

    @IBOutlet weak var todoField: UITextField!
    @IBOutlet weak var placePickerView: UIPickerView!
    var task: Todo? = nil
    var places: [Place]!

    override func viewDidLoad() {
        super.viewDidLoad()
        placePickerView.delegate = self
        placePickerView.dataSource = self
        if let taskTodo = task {
            todoField.text = taskTodo.item
        }
        places = Place.mr_findAll() as! [Place]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        places = Place.mr_findAll() as! [Place]
        placePickerView.reloadAllComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if task != nil {
            editTask()
        } else {
            createTask()
        }
        navigationController!.popViewController(animated: true)
    }

    func createTask() {
        let newTask: Todo = Todo.mr_createEntity()!
        newTask.item = todoField.text
        newTask.managedObjectContext!.mr_saveToPersistentStoreAndWait()
    }
    
    func editTask() {
        task?.item = todoField.text
        task?.managedObjectContext!.mr_saveToPersistentStoreAndWait()
    }
}

extension TodoItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    @available(iOS 2.0, *)
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
