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
    var eventRectangles: [CGRect] = []
    
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
        makeEventRectangles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeEventRectangles()
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


        for rect in eventRectangles {
            //TODO: - draw rectangle
        }
    }

    
    func makeEventRectangles() {
        if let daysEvents = viewControllerDelegate?.getDaysEvents() {
            for event in daysEvents {
                let rectangleStartY = activityTimeToY(time: event.startTime)
                eventRectangles.append(CGRect(x: activityStartX, y: rectangleStartY, width: activityWidth, height: activityTimeToY(time: event.endTime) - rectangleStartY))
            }
        }
    }
    
    func activityTimeToY(time: Double) -> Double {
        return firstLineY + hourVerticalPoints * time
    }
}

protocol ViewControllerDelegate {
    func getDaysEvents() -> [CalendarActivity]
}
