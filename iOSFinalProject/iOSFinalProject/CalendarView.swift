//
//  CalendarView.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 10/25/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

class CalendarView: UIView {
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    // Instantiating drawable objects here so it's not done in draw()
    var hourBezier = UIBezierPath()
    var halfHourBezier = UIBezierPath()
    var activityRectanglePaths: [UIBezierPath] = []
    
    // Location values
    let lineStartX: Double = 75
    let lineEndX: Double = 600
    let firstLineY: Double = 11
    let hourVerticalPoints: Double = 48.7
    let activityStartX: Double = 86
    let activityWidth: Double = 215
    

    
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

        UIColor.black.set()
        
        // Draw hour lines
        for index in 0...23 {
            
            hourBezier.move(to: CGPoint(x: lineStartX, y: firstLineY + hourVerticalPoints * Double(index)))
            hourBezier.addLine(to: CGPoint(x: lineEndX, y: firstLineY + hourVerticalPoints * Double(index)))
            hourBezier.close()
            hourBezier.stroke()
            hourBezier.fill()
        }
        
        UIColor.lightGray.set()
        
        for index in 0...23 {
            
            halfHourBezier.move(to: CGPoint(x: lineStartX, y: firstLineY + hourVerticalPoints / 2 + hourVerticalPoints * Double(index)))
            halfHourBezier.addLine(to: CGPoint(x: lineEndX, y: firstLineY + hourVerticalPoints / 2 + hourVerticalPoints * Double(index)))
            halfHourBezier.close()
            halfHourBezier.stroke()
            halfHourBezier.fill()
        }

        UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 0.2).set()

        // Draw activity rectangles
        for path in activityRectanglePaths {
            path.stroke()
            path.fill()
        }
    }

    // Create list of paths to be drawn
    public func makeActivityRectangles() {
        if let daysActivities = viewControllerDelegate?.getDaysActivities() {
            for activity in daysActivities {
                let rectangleStartY = activityTimeToY(time: activity.startTime)
                let rect = CGRect(x: activityStartX, y: rectangleStartY, width: activityWidth, height: activityTimeToY(time: activity.endTime) - rectangleStartY)
                
                let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0))
                path.close()
                activityRectanglePaths.append(path)
            }
        }
    }
    
    func activityTimeToY(time: Double) -> Double {
        return firstLineY + hourVerticalPoints * time
    }
}

protocol ViewControllerDelegate {
    func getDaysActivities() -> [CalendarActivity]
}
