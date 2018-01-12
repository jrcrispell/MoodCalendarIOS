//
//  Arrow.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/14/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

class Arrow: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        

        self.transform = CGAffineTransform(rotationAngle: 1.5708)
    }
 

}
