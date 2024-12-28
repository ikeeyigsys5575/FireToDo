//
//  TasksViewController.swift
//  FireToDo
//
//  Created by ikeeyigsys5575 on 12/25/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TasksViewController: UITableViewController, ModalViewControllerDelegate {

    var db : Firestore!
    var user : User!
    var tasks : [Task] = []
    var buttonTitle : String = "Add Task"
    var sendTask : Task!
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTasks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        fetchTasks()
        
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("users").document(userId).collection("tasks").addSnapshotListener { collectionSnapshot, error in
                
                if let error = error {
                    print("error retrieving")
                } else {
                    self.fetchTasks()
                    print("updated!")
                }
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    func fetchTasks() {
        if let userId = Auth.auth().currentUser?.uid {
            
            db.collection("users").document(userId).collection("tasks").order(by: "timestamp", descending: true).getDocuments() { snapshot, error in
                if let error = error {
                    self.showAlert(title: "Uh oh!", message: "Could not retrieve tasks.")
                } else if let documents = snapshot?.documents {
                    self.tasks = []
                    for document in documents {
//                        self.tableView.beginUpdates()
                        let id = document.documentID
                        let data = document.data()
                        let taskTitle = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let priority = data["priority"] as? Int ?? 0
                        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                        let completed = data["completed"] as? Bool ?? false
                        
                        self.tasks.append(Task(taskTitle: taskTitle, description: description, complete: completed, priority: priority, timestamp: timestamp, id: id))
                        
//                        self.tableView.endUpdates()
                        
                    }
                    
                    var incompleteTasks : [Task] = []
                    var completeTasks : [Task] = []
                    for i in 0..<self.tasks.count {
                        if self.tasks[i].complete {
                            completeTasks.append(self.tasks[i])
                        } else {
                            incompleteTasks.append(self.tasks[i])
                        }
                    }
                    
                    self.tasks = incompleteTasks + completeTasks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("finishedloading")
                    }
                    
                }
            }
        }
        
        print(tasks.count)
        
    }
    
    func showAlert(title: String, message: String) {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            
        }
        
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }
    
    func deleteTask(indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("users").document(userId).collection("tasks").document(task.id).delete { error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Could not delete task.")
                } else {
//                    self.tasks.remove(at: indexPath.row)
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        
    }
    
    func toggleCompleteTask(indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).collection("tasks").document(task.id).updateData([
            "completed": !task.complete
        ]) { error in
            if let error = error {
                print("Error adding task: \(error)")
                self.showAlert(title: "Uh oh!", message: "Something went wrong while editing the task. Please try again later.")
            } else {
                print("Task successfully edited!")
//                self.fetchTasks()
            }        }
        
        
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellId", for: indexPath)

        // Configure the cell...
        let task = tasks[indexPath.row]
        let attributedString: NSMutableAttributedString
        if task.complete {
            attributedString = NSMutableAttributedString(string: task.taskTitle)
                attributedString.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSRange(location: 0, length: task.taskTitle.count)
                )
            } else {
                attributedString = NSMutableAttributedString(string: task.taskTitle)
            }
        
        
        cell.textLabel?.attributedText = attributedString

        
        
        var taskPriority : Int = tasks[indexPath.row].priority
        var priorityText : String = ""
        for _ in 0...taskPriority {
            priorityText.append("🔥")
        }
        
        cell.detailTextLabel?.text = String(priorityText)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendTask = tasks[indexPath.row]
        buttonTitle = "Save Changes"
        performSegue(withIdentifier: "addTaskSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func signOutButtonClicked(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch let signOutError {
            showAlert(title: "Error", message: "Could not sign out: \(signOutError.localizedDescription)")
        }
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        buttonTitle = "Add Task"
        performSegue(withIdentifier: "addTaskSegue", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteTask(indexPath: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Toggle Complete") {
            [weak self] (action, view, completionHandler) in
            self?.toggleCompleteTask(indexPath: indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTaskSegue" {
            if let modalVC = segue.destination as? AddTaskViewController {
                modalVC.delegate = self
                if buttonTitle == "Save Changes" {
                    modalVC.buttonTitle = buttonTitle
                    modalVC.editTask = sendTask
                }
            }
            
        }
    }
    
    
    

}

struct Task {
    var taskTitle : String
    var description : String
    var complete : Bool
    var priority : Int
    var timestamp : Timestamp
    var id : String
}
