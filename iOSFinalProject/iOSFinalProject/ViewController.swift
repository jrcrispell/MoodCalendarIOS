//
//  ViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 9/27/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ViewControllerDelegate {
    
    // Date data
    var displayedDate = Date()

    // Header
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    var daysActivities = [CalendarActivity]()
    
    @IBOutlet weak var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date
        updateDate()
        
        daysActivities.append(CalendarActivity(startTime: 8, endTime: 9, activityDescription: "Test", moodScore: 8))
        daysActivities.append(CalendarActivity(startTime: 9, endTime: 10, activityDescription: "Test2", moodScore: 6))

        daysActivities.append(CalendarActivity(startTime: 9.5, endTime: 12, activityDescription: "Test3", moodScore: 2))

        
        // Set delegate
        calendarView.viewControllerDelegate = self
        calendarView.makeActivityDrawables()
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
    
    func updateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: displayedDate)
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
            performSegue(withIdentifier: "toLogger", sender: sender)
        }
    }

    @IBAction func calendarViewLongPress(_ sender: UILongPressGestureRecognizer) {
        print("Long Press")
    }
    
    

}

