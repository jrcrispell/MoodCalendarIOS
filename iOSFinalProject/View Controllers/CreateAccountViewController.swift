//
//  LoginViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseAuth



class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var invalidEmail: UILabel!

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var user: User!
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        
        emailField.addTarget(self, action: #selector(validateEmail(_:)), for: .editingChanged)
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            passwordField.becomeFirstResponder()
        }
        if textField.tag == 2 {
            confirmPasswordField.becomeFirstResponder()
        }
        if textField.tag == 3 {
            createTapped(textField)
        }
        return true
    }

    @IBAction func createTapped(_ sender: Any) {
        
        email = emailField.text!
        password = passwordField.text!
            
            // Confirm passwords match
            if confirmPasswordField.text! != password {
                self.present(Utils.makeSimpleAlert(title: "Error", message: "Passwords do not match"), animated: true, completion: nil)
                return
            }

            // Create user
            Auth.auth().createUser(withEmail: self.email, password: self.password) { (user, error) in
                // Error handling
                if error != nil {
                    self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
                }
                    // Log in
                else {
                    Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                        if error != nil {
                            self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
                        }
                    }
                }
            }

    
    }
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func validateEmail(_ sender: UITextField) {
        
        // credit https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift

            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: sender.text) {
            invalidEmail.isHidden = true
        } else {
            invalidEmail.isHidden = false
        }
    }
}
