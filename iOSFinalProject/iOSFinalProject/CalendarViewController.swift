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

let g_dateFormatter = DateFormatter()


class CalendarViewController: UIViewController, ViewControllerDelegate {
    
    
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
    
    var sendStartTime: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date
        g_dateFormatter.dateFormat = "MMM d, yyyy"
        updateDate()
        
        // Authorized Firebase user
        user = Auth.auth().currentUser
        
        // Set delegate
        calendarView.viewControllerDelegate = self
        
    }
    
    func loadEvents() {
        
        
        //TODO: - this is unsecure, set up database rules
        let ref = Database.database().reference()
        let displayedDateRef = ref.child(user.uid).child(dateString)
        displayedDateRef.observeSingleEvent(of: .value, with:{ (snapshot) in
            self.daysActivities = []            

            guard let activityDictionary = snapshot.value as? [String:Any] else {
                print("No existing activities")
                self.calendarView.makeActivityDrawables()
                self.calendarView.setNeedsDisplay()
                return
            }
            let activityIds = Array(activityDictionary.keys)
            for id in activityIds {
                guard let values = activityDictionary[id] as? [String:Any],
                let startTime = values["startTime"] as? Double,
                let endTime = values["endTime"] as? Double,
                let activityDescription = values["activityDescription"] as? String,
                    let moodScore = values["moodScore"] as? Double else {continue}
                
                self.daysActivities.append(CalendarActivity(databaseID: id, startTime: startTime, endTime: endTime, activityDescription: activityDescription, moodScore: Int(moodScore)))
            }
            self.calendarView.makeActivityDrawables()
            self.calendarView.setNeedsDisplay()

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
        loadEvents()
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
        dateString = g_dateFormatter.string(from: displayedDate)
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
        
        // Calculate start hour where user clicked, will be sent in prepare function
        sendStartTime = Double(Int(CalendarView.convertYToHour(point.y)))
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
            loggerView.displayedDate = displayedDate
            loggerView.incomingStartTime = sendStartTime
            loggerView.incomingEndTime = sendStartTime + 1
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editingActivity = nil
        loadEvents()
    }
}

