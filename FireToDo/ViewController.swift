//
//  ViewController.swift
//  FireToDo
//
//  Created by ikeeyigsys5575 on 12/24/24.
//

import UIKit

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var user : User? = nil
    
    var db : Firestore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        FirebaseApp.configure()
        
        title = "Authenticate"
        
        db = Firestore.firestore()
        
        passwordTextField.text = ""
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        if let email = emailTextField.text {
            if let password = passwordTextField.text {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    
                    if let error = error as? NSError {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .operationNotAllowed:
                            self.showAlert(title: "Sign up failed", message: "Sign up is disabled at this time. Try again later.")
                        case .emailAlreadyInUse:
                            self.showAlert(title: "Sign up failed", message: "Email is already in use")
                        case .invalidEmail:
                            self.showAlert(title: "Sign up failed", message: "Invalid email entered")
                        case .weakPassword:
                            self.showAlert(title: "Sign up failed", message: "Password is too weak")
                        default:
                            self.showAlert(title: "Sign up failed", message: "Unknown error occurred.")
                        }
                        
                    } else {
                        let newUserInfo = Auth.auth().currentUser
                        print(self.user?.email)
                        self.performSegue(withIdentifier: "showTasksSegue", sender: self)
                    }
                }
            }
            
        }
    }
    
    @IBAction func signInButtonClicked(_ sender: Any) {
        
        if let email = emailTextField.text {
            if let password = passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    
                    
                    if let error = error as? NSError {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .operationNotAllowed:
                            self.showAlert(title: "Login failed", message: "Login is currently disabled. Try again later.")
                        case .userDisabled:
                            self.showAlert(title: "Login failed", message: "This user is disabled.")
                        case .wrongPassword:
                            self.showAlert(title: "Login failed", message: "Incorrect password")
                        case .invalidEmail:
                            self.showAlert(title: "Login failed", message: "Invalid email entered")
                        default:
                            self.showAlert(title: "Login failed", message: "Unknown error occurred")
                        }
                    } else {
                        self.user = Auth.auth().currentUser
                        print(self.user?.email)
                        self.performSegue(withIdentifier: "showTasksSegue", sender: self)
                    }
                }
            }
            
        }
    }
    
    func showAlert(title: String, message: String) {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            
        }
        
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTasksSegue" {
            if let taskTVC = segue.destination as? TasksViewController {
                taskTVC.db = self.db
                taskTVC.user = self.user
            }
        }
    }
    
    
    
    
}

