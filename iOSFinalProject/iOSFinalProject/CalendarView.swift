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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)


    }
    
    override func draw(_ rect: CGRect) {

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
