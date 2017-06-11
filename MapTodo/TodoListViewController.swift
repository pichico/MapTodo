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

class TodoListViewController: AppViewController {

    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var todoListItemCell: UITableViewCell!
    var todoEntries: Results<Todo>!
    var placeEntries: Results<Place>!

    var realm: Realm! = MapTodoRealm.sharedRealm.realm

    override func viewDidLoad() {
        super.viewDidLoad()
        todoEntries = Todo.getAll()
        placeEntries = Place.getAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todoEntries = Todo.getAll()
        todoListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let todoController = segue.destination as! TodoItemViewController
            todoController.task = todo(indexPath: todoListTableView.indexPathForSelectedRow!)
        }
    }

    func place(section: Int) -> Place? {
        return placeEntries.count > section ? placeEntries[section] : nil
    }

    func todoEntries(section: Int) -> Results<Todo>? {
        if let p = place(section: section) {
            return todoEntries.filter("place = %@", p)
        } else {
            return nil
        }
    }

    func todo(indexPath: IndexPath) -> Todo? {
        if let todoList = todoEntries(section: indexPath.section) {
            if todoList.count > indexPath.row {
                return todoList[indexPath.row]
            }
        }
        return nil
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: AppTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlaceItem") as! AppTableViewCell
        cell.textLabel?.text = place(section: section)!.name
        cell.isTop = true
        cell.isBottom = (tableView.numberOfRows(inSection: section) == 0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

}

extension TodoListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return placeEntries.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoEntries(section: section)!.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TodoListItem") as! TextFieldTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        if let todo = todo(indexPath: indexPath) {
            cell.textField.text = todo.item
            cell.isBottom = false
        } else {
            cell.textField.text = ""
            cell.isBottom = true
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todo(indexPath: indexPath)?.delete()
            todoListTableView.reloadData()
        }
    }
}

extension TodoListViewController: TextFieldTableViewCellDelegate {
    func textFieldDidEndEditing(cell: TextFieldTableViewCell, value: NSString, indexPath: IndexPath) {
        let todo: Todo = self.todo(indexPath: indexPath) ?? Todo()
        try! realm.write {
            todo.replace(item: value as String, place: place(section: indexPath.section)!)
        }
        todoListTableView.reloadData()
    }
}
