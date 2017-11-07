//
//  LoggerViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/6/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

class LoggerViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var editingActivity: CalendarActivity!
    
    var displayedDate = Date()

    @IBOutlet weak var dateLabel: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editingActivity == nil {
            deleteButton.isEnabled = false
        }
        
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationBar.isTranslucent = true
        navigationBar.isOpaque = true
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        //navigationBar.tintColor = UIColor.clear
        if (self.navigationController) != nil
        {
            print("exists")
        }
        else {
            print("nope")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"        
        dateLabel.title = dateFormatter.string(from: displayedDate)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender:UIBarButtonItem) {
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem) {
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
