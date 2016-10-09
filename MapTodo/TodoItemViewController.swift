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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        let newTask: Todo = Todo.mr_createEntity()!
        newTask.item = todoField.text
        newTask.managedObjectContext!.mr_saveToPersistentStoreAndWait()
        navigationController!.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
