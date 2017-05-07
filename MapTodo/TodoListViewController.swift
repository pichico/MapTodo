//
//  ViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/08.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreData
import CoreLocation
import RealmSwift
import UIKit

class TodoListViewController: UIViewController {

    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var todoListItemCell: UITableViewCell!
    var todoEntities: Results<Todo>!
    var placeEntities: Results<Place>!

    var realm: Realm! = MapTodoRealm.sharedRealm.realm

    override func viewDidLoad() {
        super.viewDidLoad()
        todoEntities = Todo.getAll()
        placeEntities = Place.getAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todoEntities = Todo.getAll()
        todoListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let todoController = segue.destination as! TodoItemViewController
            todoController.task = todoEntities[todoListTableView.indexPathForSelectedRow!.row]
        }
    }    
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return placeEntities.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return placeEntities[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoEntities.filter("place = %@", placeEntities[section]).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TodoListItem")
        cell.textLabel?.text = todoEntities.filter("place = %@", placeEntities[indexPath.section])[indexPath.row].item
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todoEntities.filter("place = %@", placeEntities[indexPath.section])[indexPath.row].delete()
            todoListTableView.reloadData()
        }
    }
}
