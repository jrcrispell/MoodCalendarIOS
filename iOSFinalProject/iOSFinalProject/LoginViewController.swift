//
//  LoginViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseAuth



class LoginViewController: BaseViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var user: User!
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        
        user = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "toCalendarView", sender: self)
            }
            else {
                // Pop to root
                
                //TODO: - probably bugged if user somehow signs out from somewhere other than
                // CalendarViewController
                if let presentedViewController = self.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }
            }
        }
    }

    @IBAction func registerTapped(_ sender: Any) {
        
        email = emailField.text!
        password = passwordField.text!
        
        let alert = UIAlertController(title: "Verify Password", message: "Please re-enter password to confirm", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmButton = UIAlertAction(title: "Confirm", style: .default) { (action) in

            let textField = alert.textFields![0] as UITextField
            
            // Confirm passwords match
            if textField.text! != self.password {
                self.present(Utils.makeSimpleAlert(title: "Error", message: "Passwords do not match"), animated: true, completion: nil)
            }

            // Create user
            Auth.auth().createUser(withEmail: self.email, password: self.password) { (user, error) in
                // Error handling
                if error != nil {
                    self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
                }
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        alert.addAction(cancelButton)
        alert.addAction(confirmButton)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        email = emailField.text!
        password = passwordField.text!
        
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func forgotTapped(_ sender: Any) {
        
        email = emailField.text!
        password = passwordField.text!
        
        if email == "" {
            self.present(Utils.makeSimpleAlert(title: "Error", message: "Enter email address before clicking Forgot Password"), animated: true, completion: nil)
        }
            // Send reset email
        else {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if error != nil {
                    self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
                }
                else {
                    self.present(Utils.makeSimpleAlert(title: "Email sent", message: "Reset password email has been sent"), animated: true, completion: nil)
                }
            })
        }
    }
    
    //MARK: Helper Methods
    


    
     //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         let calendarViewController = segue.destination as! CalendarViewController
//        calendarViewController.user = self.user
    }
 

}
