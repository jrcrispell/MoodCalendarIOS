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
let g_lineStartX: Double = 75
let g_lineEndX: Double = 600
let g_firstLineY: Double = 11
let g_hourVerticalPoints: Double = 48.7
let g_activityWidth: Double = 400
let g_moodXPosition:Double = 380
let g_hourLabelX: Double = 16
let g_firstTextLabelY: Double = 0

class CalendarView: UIView {
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    // Instantiating drawable objects here so it's not done in draw()
    //var hourBezier = UIBezierPath()
    var halfHourBezier = UIBezierPath()
    var activityDrawables: [ActivityDrawables] = []
    var hourLabels: [NSString] = []

    // Old globals
//    var g_moodRectangleXPosition = 315
//    var g_moodValueIndentation = 17
//    var g_moodRectangleWidth = 120
//    var g_draggableLineHeight: Double = 10
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        // Draw hour lines
        for index in 0...23 {
            Styles.white50Percent.setStroke()
            let hourBezier = UIBezierPath()
            hourBezier.move(to: CGPoint(x: g_lineStartX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.addLine(to: CGPoint(x: g_lineEndX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.stroke()
            
            // Draw label
            var hourString = NSString()
            if index == 0 {
                hourString = "12:00"
            }
            else if index == 12 {
                hourString = "12:00"
            }
            else if index < 12 {
                hourString = String(index) + ":00" as NSString
            }
            else {
                hourString = String(index - 12) + ":00" as NSString
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
        if let daysActivities = viewControllerDelegate?.getDaysActivities() {
            for activity in daysActivities {
                activityDrawables.append(ActivityDrawables(activity: activity))
            }
        }
    }
    
    public static func activityTimeToY(time: Double) -> Double {
        return g_firstLineY + g_hourVerticalPoints * time
    }
    
    public func getSelectedActivity(location: CGPoint) -> CalendarActivity? {
        // Verify x position
        if Double(location.x) < g_lineStartX {return nil}
        let timeClicked = CalendarView.convertYToHour(location.y)
        guard let daysActivities = viewControllerDelegate?.getDaysActivities() else { return nil }
            for activity in daysActivities {
                if timeClicked > activity.startTime && timeClicked < activity.endTime {
                    return activity
                }
        }
        return nil
    }
    
    // Converts the CGFloat value of a Y coordinate to a double that corresponds to the hour on the calendarView
    static func convertYToHour(_ y: CGFloat) -> Double {
        return (Double(y) - g_firstLineY)/g_hourVerticalPoints
    }
}

protocol ViewControllerDelegate {
    func getDaysActivities() -> [CalendarActivity]
}
