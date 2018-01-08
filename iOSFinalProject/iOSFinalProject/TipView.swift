//
//  TipView.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 1/7/18.
//  Copyright © 2018 Crispell Apps. All rights reserved.
//

import UIKit

class TipView: UIView {

    @IBOutlet weak var tipLine1: UILabel!
    @IBOutlet weak var tipLine2: UILabel!
    
    @IBAction func closeTapped(_ sender: Any) {
        self.removeFromSuperview()
    }
}
