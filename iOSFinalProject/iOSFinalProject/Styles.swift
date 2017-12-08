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
    static let accentColor = UIColor(red: 0.078431, green: 0.32549, blue: 0.43137, alpha: 1.0)
    
    
    static var textAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): white80Percent, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): textStyle, NSAttributedStringKey(rawValue: NSAttributedStringKey.obliqueness.rawValue): 0.1, NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): textFont!]
    
    static var moodPickerAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): white80Percent, NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): textFont!]
    
    
}
