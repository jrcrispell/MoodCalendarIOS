//
//  ActivityDrawables.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/1/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

public class ActivityDrawables: NSObject {
    
    // Drawable objects
    let rectanglePath: UIBezierPath
    let activityDescription: NSString
    let mood: NSString
    let rectangle: CGRect
    
    // Attributes
    let textColor = UIColor.darkGray
    let textFont = UIFont(name: "Helvetica Neue", size: 18)
    let textStyle = NSMutableParagraphStyle()
    let textAttributes: NSDictionary
    
    init(activity: CalendarActivity) {
        
        textStyle.lineSpacing = 6.0
        
        textAttributes = [NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: textStyle, NSObliquenessAttributeName: 0.1, NSFontAttributeName: textFont!]
        
        mood = String(activity.moodScore) as NSString
        
        let rectangleStartY = CalendarView.activityTimeToY(time: activity.startTime)
        rectangle = CGRect(x: g_activityStartX, y: rectangleStartY, width: g_activityWidth, height: CalendarView.activityTimeToY(time: activity.endTime) - rectangleStartY)
        
        rectanglePath = UIBezierPath(roundedRect: rectangle, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0))
        rectanglePath.close()
        
        activityDescription = "  " + activity.activityDescription as NSString

        super.init()
        
    }
    
    func draw() {
        activityDescription.draw(in: rectangle, withAttributes: textAttributes as? [String : Any])
    }
}
