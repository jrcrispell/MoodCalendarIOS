//
//  ViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 9/27/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class CalendarViewController: UIViewController, ViewControllerDelegate {
    
    let dateFormatter = DateFormatter()
    
    // Date data
    var displayedDate = Date()
    var dateString = ""

    // Header
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    var daysActivities = [CalendarActivity]()
    
    @IBOutlet weak var calendarView: CalendarView!
    
    var editingActivity: CalendarActivity!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date
        dateFormatter.dateFormat = "MMM d, yyyy"
        updateDate()
        
        // Authorized Firebase user
        user = Auth.auth().currentUser
        
        loadEvents()

        
        // Set delegate
        calendarView.viewControllerDelegate = self
        calendarView.makeActivityDrawables()
    }
    
    func loadEvents() {
        
        //TODO: - this is unsecure, set up database rules
        let ref = Database.database().reference()
        let displayedDateRef = ref.child(user.uid).child(dateString)
        displayedDateRef.observe(.value, with:{ (snapshot) in
            
            self.daysActivities = []

            guard let activityDictionary = snapshot.value as? [String:Any] else {
                print("activityDictionaryERROR")
                return
            }
            let keys = Array(activityDictionary.keys)
            for key in keys {
                let values = activityDictionary[key] as! [String:Any]
                let startTime = values["startTime"] as! Double
                let endTime = values["endTime"] as! Double
                let activityDescription = values["activityDescription"] as! String
                let moodScore = values["moodScore"] as! Int
                
                //TODO: - get database ID
                self.daysActivities.append(CalendarActivity(databaseID: "1", startTime: startTime, endTime: endTime, activityDescription: activityDescription, moodScore: moodScore))
            }
            
        })
        
        return
    }
    
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        
        
        let calendar = Calendar.current
        // Back arrow
        if sender.tag == 0 {
            displayedDate = calendar.date(byAdding: .day, value: -1, to: displayedDate)!
        }
            
        // Forward arrow
        else {
            displayedDate = calendar.date(byAdding: .day, value: 1, to: displayedDate)!
        }
        updateDate()
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            self.present(AlertUtils.makeSimpleAlert(title: "Sign out error", message: error.localizedDescription), animated: true, completion: nil)
        }
    }
    
    
    func updateDate() {
        dateString = dateFormatter.string(from: displayedDate)
        dateButton.setTitle(dateString, for: .normal)
    }
    
    func getDaysActivities() -> [CalendarActivity] {
        return daysActivities
    }
    
    @IBAction func calendarViewTapped(_ sender: UITapGestureRecognizer) {
        print("Tap")
        print(sender.description)
        let point = sender.location(in: calendarView)
        print(point.x.description + " , " + point.y.description)
        if let activity = calendarView.getSelectedActivity(location: point) {
            editingActivity = activity
        }
        performSegue(withIdentifier: "toLogger", sender: sender)

    }

    @IBAction func calendarViewLongPress(_ sender: UILongPressGestureRecognizer) {
        print("Long Press")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogger" {
            guard let loggerView = segue.destination as? LoggerViewController else {return}
            if editingActivity != nil {
                loggerView.editingActivity = editingActivity
            }
            // Making new activity
            print(Date().timeIntervalSince1970.hashValue.description)
            loggerView.displayedDate = displayedDate
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editingActivity = nil
    }
}

