//
//  LoginViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email = emailField.text!
        password = passwordField.text!

        // Do any additional setup after loading the view.
    }

    @IBAction func registerTapped(_ sender: Any) {
        

        
        let alert = UIAlertController(title: "Verify Password", message: "Please re-enter password to confirm", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmButton = UIAlertAction(title: "Confirm", style: .default) { (action) in

            let textField = alert.textFields![0] as UITextField
            
            // Confirm passwords match
            if textField.text! != self.password {
                self.present(self.makeErrorAlert(message: "Passwords do not match"), animated: true, completion: nil)
            }

            // Create user
            Auth.auth().createUser(withEmail: self.email, password: self.password) { (user, error) in
                // Error handling
                if error != nil {
                    self.present(self.makeErrorAlert(message: error!.localizedDescription), animated: true, completion: nil)
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
        //segue id: toCalendarView
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.present(self.makeErrorAlert(message: error!.localizedDescription), animated: true, completion: nil)
            }
            else {
                
            }
        }
        
    }
    @IBAction func forgotTapped(_ sender: Any) {
    }
    
    //MARK: Helper Methods
    
    func makeErrorAlert(message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okButton)
        return errorAlert
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
