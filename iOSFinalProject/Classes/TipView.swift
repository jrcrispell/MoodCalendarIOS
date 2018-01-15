//
//  TipView.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 1/7/18.
//  Copyright © 2018 Crispell Apps. All rights reserved.
//

import UIKit

protocol TipViewShowing {
    func removeTipView()
}

class TipView: UIView {
    
    var tipShower: TipViewShowing!
    
    //TODO: some weird interaction between dragging, exiting logger view, and trying to close pro tip view

    @IBOutlet weak var tipLine1: UILabel!
    @IBOutlet weak var tipLine2: UILabel!
    
    @IBAction func closeTapped(_ sender: Any) {
        tipShower.removeTipView()
        self.removeFromSuperview()
    }
}
