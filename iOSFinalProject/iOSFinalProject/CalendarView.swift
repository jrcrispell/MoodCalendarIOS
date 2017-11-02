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
let g_moodXPosition:Double = 332


class CalendarView: UIView {
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    // Instantiating drawable objects here so it's not done in draw()
    var hourBezier = UIBezierPath()
    var halfHourBezier = UIBezierPath()
    var activityDrawables: [ActivityDrawables] = []
    
    
    // Colors
    var white20Percent = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    

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

        white20Percent.set()
        
        // Draw hour lines
        for index in 0...23 {
            
            hourBezier.move(to: CGPoint(x: g_lineStartX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.addLine(to: CGPoint(x: g_lineEndX, y: g_firstLineY + g_hourVerticalPoints * Double(index)))
            hourBezier.close()
            hourBezier.stroke(with: .normal, alpha: 0.2)
        }

        // Draw activity rectangles
        for drawable in activityDrawables {
            drawable.draw()
        }
    }

    public func makeActivityDrawables() {
        if let daysActivities = viewControllerDelegate?.getDaysActivities() {
            for activity in daysActivities {

                activityDrawables.append(ActivityDrawables(activity: activity))
            }
        }
    }
    
    public static func activityTimeToY(time: Double) -> Double {
        return g_firstLineY + g_hourVerticalPoints * time
    }

}

protocol ViewControllerDelegate {
    func getDaysActivities() -> [CalendarActivity]
}
