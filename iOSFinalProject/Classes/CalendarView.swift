//
//  CalendarView.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 10/25/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

// Global Location values
let g_lineStartX: Double = 90
let g_lineEndX: Double = 600
let g_firstLineY: Double = 21
var g_hourVerticalPoints: Double = 80
//let g_hourVerticalPoints: Double = 80

let g_activityWidth: Double = 400
let g_moodXPosition:Double = 340
let g_hourLabelX: Double = 8
let g_firstTextLabelY: Double = 10

class CalendarView: UIView {
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    // Instantiating drawable objects here so it's not done in draw()
    var halfHourBezier = UIBezierPath()
    var activityDrawables: [ActivityDrawables] = []
    var hourLabels: [NSString] = []
    
    var daysActivities: [CalendarActivity]?

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        // Draw hour lines
        for index in 0...23 {
            
            var shouldDraw = true
            
            // Don't draw the hour line if it's behind an activity
            if daysActivities != nil {
                for activity in daysActivities! {
                    if activity.startTime < Double(index) && activity.endTime > Double(index) {
                        shouldDraw = false
                    }
                }
            }
            
            if (shouldDraw) {
            Styles.white50Percent.setStroke()
            let hourBezier = UIBezierPath()
            hourBezier.move(to: CGPoint(x: g_lineStartX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.addLine(to: CGPoint(x: g_lineEndX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.stroke()
            
            }
            // Draw label
            var hourString = NSString()
            if index == 0 {
                hourString = "12:00 am"
            }
            else if index == 12 {
                hourString = "12:00 pm"
            }
            else if index == 11 || index == 10 {
                hourString = String(index) + ":00 am" as NSString
            }
                
                // Adding a space at the beginning so the hours are right-aligned
            else if index < 10 {
                hourString = "  " + String(index) + ":00 am" as NSString
            }
            else if index < 22 {
                hourString = "  " + String(index - 12) + ":00 pm" as NSString
            }
            else {
                hourString = String(index - 12) + ":00 pm" as NSString
            }
            hourString.draw(at: CGPoint(x: g_hourLabelX, y: g_firstTextLabelY + Double(index) * g_hourVerticalPoints), withAttributes: Styles.textAttributes)
        }
        

        // Draw activity rectangles
        for drawable in activityDrawables {
            drawable.draw()
        }
    }

    public func makeActivityDrawables() {
        activityDrawables = []
        daysActivities = (viewControllerDelegate?.getDaysActivities())
        
        if daysActivities != nil {
            for activity in daysActivities! {
                activityDrawables.append(ActivityDrawables(activity: activity))
            }
        }
        
    }
    
    public func getSelectedActivity(location: CGPoint) -> CalendarActivity? {
        // Verify x position
        if Double(location.x) < g_lineStartX {return nil}
        let timeClicked = Utils.convertYToHour(location.y)
        guard let daysActivities = viewControllerDelegate?.getDaysActivities() else { return nil }
            for activity in daysActivities {
                if timeClicked > activity.startTime && timeClicked < activity.endTime {
                    return activity
                }
        }
        return nil
    }
    


}

protocol ViewControllerDelegate {
    func getDaysActivities() -> [CalendarActivity]
}
