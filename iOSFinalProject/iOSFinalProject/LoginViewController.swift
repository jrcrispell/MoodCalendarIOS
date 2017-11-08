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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func registerTapped(_ sender: Any) {
        
        let email = emailField.text!
        let password = passwordField.text!
        
        let alert = UIAlertController(title: "Verify Password", message: "Please re-enter password to confirm", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmButton = UIAlertAction(title: "Confirm", style: .default) { (action) in

            let textField = alert.textFields![0] as UITextField
            let typed = textField.text!
            print("verify" + typed)

//            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//                // Error handling
//            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        alert.addAction(cancelButton)
        alert.addAction(confirmButton)
        present(alert, animated: true, completion: nil)
        
        

    }
    
    @IBAction func loginTapped(_ sender: Any) {
    }
    @IBAction func forgotTapped(_ sender: Any) {
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
