//
//  CalendarActivity.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 10/25/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class CalendarActivity: NSObject {
    
    var databaseID: String?
    var startTime: Double
    var endTime: Double
    var activityDescription: String
    var moodScore: Int
    
    required init(databaseID: String?, startTime: Double, endTime: Double, activityDescription: String, moodScore: Int) {
        if databaseID != nil {
        self.databaseID = databaseID
        }
        self.startTime = startTime
        self.endTime = endTime
        self.activityDescription = activityDescription
        self.moodScore = moodScore
    }
    
    static func saveToDatabase(date: String, activity: CalendarActivity, database: DatabaseReference, user: User) {
                
        let dateRef = database.child(user.uid).child(date)
        var activityRef: DatabaseReference!
        
        if activity.databaseID != nil {
            activityRef = dateRef.child(activity.databaseID!)
        }
        else {
            activityRef = dateRef.childByAutoId()
            activity.databaseID = activityRef.key
        }
        
        // Save values to database
        activityRef.child("startTime").setValue(dateToTime(date: startTime))
        activityRef.child("endTime").setValue(dateToTime(date: endTime))
        activityRef.child("activityDescription").setValue(descriptionField.text)
        activityRef.child("moodScore").setValue(Double(moodScore))

    }
    
}
