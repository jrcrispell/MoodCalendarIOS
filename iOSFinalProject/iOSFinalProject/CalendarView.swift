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
    
    // Attributes
    let textFont = UIFont(name: "Helvetica Neue", size: 18)
    let textStyle = NSMutableParagraphStyle()
    var textAttributes: [String : Any]?
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    // Instantiating drawable objects here so it's not done in draw()
    var hourBezier = UIBezierPath()
    var halfHourBezier = UIBezierPath()
    var activityDrawables: [ActivityDrawables] = []
    var hourLabels: [NSString] = []
    
    
    // Colors
    let white20Percent = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    //let white80Percent = UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 0.8)
    let white80Percent = UIColor.white.withAlphaComponent(0.80)


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
            hourBezier.stroke()
            //hourBezier.stroke(with: .normal, alpha: 0.2)
        }

        // Draw hour labels
        textStyle.lineSpacing = 6.0
        textAttributes = [NSForegroundColorAttributeName: white80Percent, NSParagraphStyleAttributeName: textStyle, NSObliquenessAttributeName: 0.1, NSFontAttributeName: textFont!]
        
        for (index, label) in hourLabels.enumerated() {
            label.draw(at: CGPoint(x: g_hourLabelX, y: g_firstTextLabelY + g_hourVerticalPoints * Double (index)), withAttributes: textAttributes)
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
        
        // Configure hour labels
        for index in 0...23 {
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
            hourLabels.append(hourString)
                }
    }
    
    public static func activityTimeToY(time: Double) -> Double {
        return g_firstLineY + g_hourVerticalPoints * time
    }

}

protocol ViewControllerDelegate {
    func getDaysActivities() -> [CalendarActivity]
}
