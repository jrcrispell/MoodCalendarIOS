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
    
    var hourBezier = UIBezierPath()
    var halfHourBezier = UIBezierPath()
    
    var lineStartX: Double = 75
    var lineEndX: Double = 600
    var firstLineY: Double = 11
    var hourVerticalPoints: Double = 48.7

    
    // Old globals
//    var g_oneHourVerticalPoints: Double = 48.7
//    var g_moodRectangleXPosition = 315
//    var g_moodValueIndentation = 17
//    var g_firstLineYPosition: Double = 11
//    var g_moodRectangleWidth = 120
//    var g_eventRectangleLeadingX: Double = 86
//    var g_eventRectangleWidth: Double = 215
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


        if let daysEvents = viewControllerDelegate?.getDaysEvents() {
        for event in daysEvents {
            print(event.eventDescription)
        }
        }
    }
}

protocol ViewControllerDelegate {
    func getDaysEvents() -> [CalendarActivity]
}
