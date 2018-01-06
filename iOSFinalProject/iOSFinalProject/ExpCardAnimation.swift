//
//  ExpCardAnimation.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/29/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

class ExpCardAnimation {
    let earnedExp: Int
    let expLeft: Int
    let gaugeStartPercent: CGFloat
    let gaugeEndPercent: CGFloat
    var duration: CGFloat {
        get{
            if gaugeEndPercent - gaugeStartPercent < 0.5 {
                return 1
            }
            return (gaugeEndPercent - gaugeStartPercent) * 2
        }
    }
    let currentLevel: Int
    let nextLevel: Int
    let explanationExp: Int
    let explanationAchievement: String
    
    
    init(earnedExp: Int, expLeft: Int, gaugeStartPercent: CGFloat, gaugeEndPercent: CGFloat, currentLevel: Int, nextLevel: Int, explanationExp: Int, explanationAchievement: String) {
        self.earnedExp = earnedExp
        self.expLeft = expLeft
        self.gaugeStartPercent = gaugeStartPercent
        self.gaugeEndPercent = gaugeEndPercent
        self.currentLevel = currentLevel
        self.nextLevel = nextLevel
        self.explanationExp = explanationExp
        self.explanationAchievement = explanationAchievement
    }
}
