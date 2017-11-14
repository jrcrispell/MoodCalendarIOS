//
//  Styles.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/14/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit

class Styles {
    
    // Attributes
    static let textFont = UIFont(name: "Helvetica Neue", size: 18)
    static var textStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6.0
        return style
    }

    
    // Colors
    static let white50Percent = UIColor.white.withAlphaComponent(0.5)
    static let white80Percent = UIColor.white.withAlphaComponent(0.80)
    
    
    static var textAttributes: [String : Any] = [NSForegroundColorAttributeName: white80Percent, NSParagraphStyleAttributeName: textStyle, NSObliquenessAttributeName: 0.1, NSFontAttributeName: textFont!]
    
    static var moodPickerAttributes: [String : Any] = [NSForegroundColorAttributeName: white80Percent, NSFontAttributeName: textFont!]
    
}
