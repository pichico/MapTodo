//
//  ViewController.swift
//  MapTodo
//
//  Created by Hitomi Fukushima on 2016/10/08.
//  Copyright © 2016年 fukushima. All rights reserved.
//

import CoreData
import CoreLocation
import Instructions
import RealmSwift
import UIKit

class TodoListViewController: AppViewController {

    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var todoListItemCell: UITableViewCell!
    @IBOutlet weak var addPlaceButton: UIBarButtonItem!

    let coachMarksController = CoachMarksController()
    var todoEntries: Results<Todo>!
    var placeEntries: Results<Place>!
    let realm: Realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        todoEntries = Todo.getAll(realm: realm)
        placeEntries = Place.getAll(realm: realm)
        if placeEntries.count == 0 || todoEntries.count == 0 {
            coachMarksController.dataSource = self
            coachMarksController.overlay.color = UIColor.init(white: 0.5, alpha: 0.5)
            coachMarksController.start(on: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todoEntries = Todo.getAll(realm: realm)
        todoListTableView.reloadData()
        if todoEntries.count == 0 {
            coachMarksController.start(on: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func place(section: Int) -> Place? {
        return placeEntries.count > section ? placeEntries[section] : nil
    }

    func todoEntries(section: Int) -> Results<Todo>? {
        return place(section: section).map { todoEntries.filter("place = %@", $0) }
    }

    func todo(indexPath: IndexPath) -> Todo? {
        if let todoList = todoEntries(section: indexPath.section), todoList.count > indexPath.row {
                return todoList[indexPath.row]
        }
        return nil
    }

    @objc func placeButtonTapped(sender: UIButton) {
        let controller = R.storyboard.main.placeView()!
        controller.place = place(section: sender.tag)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TodoListViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let coarchMarkFor: UIView! = placeEntries.count == 0 ? addPlaceButton.value(forKey: "view") as! UIView
                                                             : todoListTableView.cellForRow(at: IndexPath(row: 0, section: 0))
        var coachmark: CoachMark = coachMarksController.helper.makeCoachMark(for: coarchMarkFor)
        coachmark.horizontalMargin = 2 // これをしておかないと矢印が四角からはみ出る...
        return coachmark
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark)
        -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        let hintText: String = placeEntries.count == 0 ? "まずはここからタスクのある場所を登録します" : "ここからどんどんタスクを追加しましょう"
        coachViews.bodyView.hintLabel.text = hintText
        coachViews.bodyView.nextLabel.text = "OK"

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: AppTableViewHeaderView = AppTableViewHeaderView()
        headerView.setLabelText(text: place(section: section)!.name)

        let placeButton = headerView.showDetailButton!
        placeButton.tag = section
        placeButton.addTarget(self, action: #selector(TodoListViewController.placeButtonTapped), for: .touchUpInside)

        return headerView
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
        let cell: TextFieldTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TodoListItem") as? TextFieldTableViewCell
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
            try! realm.write {
                todo(indexPath: indexPath)?.delete(realm: realm)
            }
            todoListTableView.reloadData()
        }
    }
}

extension TodoListViewController: TextFieldTableViewCellDelegate {
    func textFieldDidEndEditing(cell: TextFieldTableViewCell, value: String, indexPath: IndexPath) {
        let todo: Todo
        let isNew: Bool
        if self.todo(indexPath: indexPath) != nil {
            todo = self.todo(indexPath: indexPath)!
            isNew = false
        } else if !value.isEmpty {
            todo = Todo()
            isNew = true
        } else {
            return
        }

        if value != todo.item {
            try! realm.write {
                todo.replace(realm: realm, item: value, place: place(section: indexPath.section)!)
            }
            // 追加した場合、次の空白行にフォーカスをあててキーボードを出す
            todoListTableView.reloadData()
            if isNew {
                if let cell = todoListTableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) as? TextFieldTableViewCell {
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }

    func textFieldDidBeginEditing(cell: TextFieldTableViewCell) {
        // 下の方のセルに入力しようとするとキーボードでセルが隠れてしまうので、対象のセルが画面の真ん中にくるようにスクロールさせる
        let newContentOffset = todoListTableView.contentOffset.y + cell.frame.maxY - todoListTableView.bounds.minY - UIScreen.main.bounds.size.height * 0.5
        if newContentOffset >= todoListTableView.contentOffset.y {
            todoListTableView.contentOffset.y = newContentOffset
        }
    }
}
