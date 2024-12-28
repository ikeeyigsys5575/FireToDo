//
//  AddTaskViewController.swift
//  FireToDo
//
//  Created by ikeeyigsys5575 on 12/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddTaskViewController: UIViewController {
    weak var delegate: ModalViewControllerDelegate?
    
    var taskPriority : Int = 0
    var buttonTitle = "Add Task"
    var editTask : Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        updatePriorityText()
        priorityStepper.value = Double(taskPriority)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.setTitle(buttonTitle, for: .normal)
        if buttonTitle == "Save Changes" {
            titleTextField.text = editTask.taskTitle
            descriptionTextField.text = editTask.description
            taskPriority = editTask.priority
            updatePriorityText()
            priorityStepper.value = Double(taskPriority)
        }
    }
    
    
    @IBOutlet weak var priorityStepper: UIStepper!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBAction func priorityStepper(_ sender: UIStepper) {
        taskPriority = Int(priorityStepper.value)
        updatePriorityText()
        
    }
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        
        if let taskTitle = titleTextField.text {
            if let taskDescription = descriptionTextField.text {
                if taskTitle != "" {
                    if submitButton.titleLabel?.text == "Add Task" {
                        createTask(title: taskTitle, description: taskDescription, priority: taskPriority)
                    } else {
                        updateTask(title: taskTitle, description: taskDescription, priority: taskPriority, completed: false, id: editTask.id)
                    }
                    
                    
                } else {
                    showAlert(title: "Uh oh!", message: "Title cannot be blank!")
                }
            }
            
            
        }
        
        
    }
    
    func createTask(title: String, description: String, priority: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let taskRef = db.collection("users").document(userId).collection("tasks")
        let taskData: [String: Any] = [
            "title": title,
            "description": description,
            "priority" : priority,
            "timestamp" : Timestamp(),
            "completed" : false
        ]
        taskRef.addDocument(data: taskData) { error in
            if let error = error {
                print("Error adding task: \(error)")
                self.showAlert(title: "Uh oh!", message: "Something went wrong while adding to the database. Please try again later.")
            } else {
                print("Task successfully added!")
                self.delegate?.fetchTasks()
                self.dismiss(animated: true)
            }
        }
    }
    
    func updateTask(title: String, description: String, priority: Int, completed: Bool, id: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).collection("tasks").document(id).updateData([
            "title": title,
            "description": description,
            "priority": priority,
            "completed": completed
        ]) { error in
            if let error = error {
                print("Error adding task: \(error)")
                self.showAlert(title: "Uh oh!", message: "Something went wrong while editing the task. Please try again later.")
            } else {
                print("Task successfully edited!")
                print(priority)
                self.delegate?.fetchTasks()
                self.dismiss(animated: true)
            }        }
    }
    
    func updatePriorityText() {
        var priorityText : String = "Priority: "
        for _ in 0...taskPriority {
            priorityText.append("🔥")
        }
        
        priorityLabel.text = priorityText
    }
    
    
    func showAlert(title: String, message: String) {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            
        }
        
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

protocol ModalViewControllerDelegate: AnyObject {
    func fetchTasks()
}
