//
//  ExpCard.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//


import UIKit

class ExpCard: UIView {
    
    @IBOutlet weak var emptyExpBar: UIView!
    
    @IBOutlet weak var arrowView: UIView!
    
    @IBOutlet weak var earnedExpWidth: NSLayoutConstraint!
    

    public func changeExpWidth(percent: CGFloat) {
        
        earnedExpWidth.constant = -(percent * emptyExpBar.frame.width)
        
    }
}
