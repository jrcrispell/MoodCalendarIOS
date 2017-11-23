//
//  AlertUtils.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/9/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class Utils {
    static func makeSimpleAlert(title: String, message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okButton)
        return errorAlert
    }
    static func saveNewActivity(startTime: Double, endTime: Double, eventDescription: String, moodScore: Int, dateKey: String) {
        
        let ref = Database.database().reference()

        // Database references
        guard let user = Auth.auth().currentUser else {return}
        let todaysRef = ref.child(user.uid).child(dateKey)
        let activityRef = todaysRef.childByAutoId()
        
        // Save values to database
        activityRef.child("startTime").setValue(startTime)
        activityRef.child("endTime").setValue(startTime + 1)
        activityRef.child("activityDescription").setValue(eventDescription)
        activityRef.child("moodScore").setValue(Double(moodScore))    }
    
    static func saveToRef(calendar: Calendar, activityRef: DatabaseReference, startTime: Double, endTime: Double, eventDescription: String, moodScore: Int) {
        
        activityRef.child("startTime").setValue(startTime)
        activityRef.child("endTime").setValue(endTime)
        activityRef.child("activityDescription").setValue(eventDescription)
        activityRef.child("moodScore").setValue(Double(moodScore))
        
    }
    
    static func dateToTime(calendar: Calendar, date: Date) -> Double {
        
        let hour = Double(calendar.component(.hour, from: date))
        let fractional = Double(calendar.component(.minute, from: date))/60.0
        return hour + fractional
        
    }
    
        // Converts the CGFloat value of a Y coordinate to a double that corresponds to the hour on the calendarView
    static func convertYToHour(_ y: CGFloat) -> Double {
        return (Double(y) - g_firstLineY)/g_hourVerticalPoints
    }
    
    public static func converHourToY(time: Double) -> Double {
        return g_firstLineY + g_hourVerticalPoints * time
    }
}
