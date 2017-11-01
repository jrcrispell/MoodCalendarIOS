//
//  CalendarActivity.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 10/25/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

class CalendarActivity: NSObject {
    
    var startTime: Double
    var endTime: Double
    var activityDescription: String
    var moodScore: Int
    
    required init(startTime: Double, endTime: Double, activityDescription: String, moodScore: Int) {
        self.startTime = startTime
        self.endTime = endTime
        self.activityDescription = activityDescription
        self.moodScore = moodScore
    }
    
}
