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
    let moodPoint: CGPoint
    let rectangle: CGRect
    
    // Attributes
    let textColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.8)
    let textFont = UIFont(name: "Helvetica Neue", size: 18)
    let textStyle = NSMutableParagraphStyle()
    let textAttributes: [NSAttributedStringKey : Any]
    
    init(activity: CalendarActivity) {
        
        textStyle.lineSpacing = 6.0
        
        textAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): textColor, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): textStyle, NSAttributedStringKey(rawValue: NSAttributedStringKey.obliqueness.rawValue): 0.1, NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): textFont!]
        
        let rectangleStartY = Utils.converHourToY(time: activity.startTime)

        
        mood = String(activity.moodScore) as NSString
        moodPoint = CGPoint(x: g_moodXPosition, y: rectangleStartY)
        
        rectangle = CGRect(x: g_lineStartX, y: rectangleStartY, width: g_activityWidth, height: Utils.converHourToY(time: activity.endTime) - rectangleStartY)
        
        rectanglePath = UIBezierPath(roundedRect: rectangle, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0))
        rectanglePath.close()
        
        activityDescription = "  " + activity.activityDescription as NSString

        super.init()
        
    }
    
    func draw() {
        let moodValue: Int32 = self.mood.intValue
        if moodValue >= 5 {
            let alpha = CGFloat(0.02 * Double(moodValue))
            UIColor.yellow.withAlphaComponent(alpha).set()
        }
        else {
            let alpha: CGFloat = CGFloat(0.02 * Double(10 - moodValue))
            UIColor.blue.withAlphaComponent(alpha).set()
        }
        rectanglePath.fill()
        
        UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.2).set()
        
        rectanglePath.stroke()
        rectanglePath.fill()
        
        activityDescription.draw(in: rectangle, withAttributes: textAttributes)
        mood.draw(at: moodPoint, withAttributes: textAttributes)
    }
}
