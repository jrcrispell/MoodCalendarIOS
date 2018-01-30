//
//  LoginViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var invalidEmail: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var user: User!
    
    override func viewDidLoad() {
        emailField.addTarget(self, action: #selector(validateEmail(_:)), for: .editingChanged)
        user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // Go to main calendar screen when signed in.
                self.performSegue(withIdentifier: "toCalendarView", sender: self)
            }
            else {
                // Pop to login screen if signed out.
                //TODO: - probably bugged if user somehow signs out from somewhere other than
                // CalendarViewController
                if let presentedViewController = self.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        let email = emailField.text!
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func forgotTapped(_ sender: Any) {
        
        let email = emailField.text!
        
        // Prompt user to enter email address if email blank or invalid.
        if email == "" || !invalidEmail.isHidden {
            let passwordAlert = UIAlertController(title: "Reset password", message: "Enter email address to reset password", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Send Reset Email", style: .default, handler: { (alert) in
                let textField = passwordAlert.textFields![0]
                Auth.auth().sendPasswordReset(withEmail: textField.text!, completion: { (error) in
                    if error != nil {
                        self.present(Utils.makeSimpleAlert(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
                    }
                    else {
                        self.present(Utils.makeSimpleAlert(title: "Email sent", message: "Reset password email has been sent"), animated: true, completion: nil)
                    }
                })
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            passwordAlert.addAction(okButton)
            passwordAlert.addAction(cancelButton)
            passwordAlert.addTextField(configurationHandler: { (textField) in
            })
            present(passwordAlert, animated: true, completion: nil)
        }
            // Send reset email to email address that's already typed in.
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
    
    // Keyboard enter functionality
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            passwordField.becomeFirstResponder()
        }
        if textField.tag == 2 {
            loginTapped(textField)
        }
        return true
    }
}
