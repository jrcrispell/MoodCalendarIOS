//
//  MenuView.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/25/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    @IBOutlet weak var chartsIcon: UIImageView!
    
    @IBOutlet weak var homeIcon: UIImageView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var dataVisButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var notifyButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setInitialPosition(bounds: CGRect) {

        self.frame = CGRect(x: -bounds.width, y: bounds.height / 2 - bounds.height * 0.4 / 2, width: bounds.width * 0.6, height: bounds.height)
    }

    func animateIn(snapshotView: UIImageView, bounds: CGRect) {
        
        let smallSnapshotWidth = bounds.width * 0.4
        let smallSnapshotHeight = bounds.height * 0.4
        
        UIView.animate(withDuration: 0.3, animations: {
            snapshotView.frame = (CGRect(x: bounds.width - smallSnapshotWidth / 2, y: bounds.height / 2 - smallSnapshotHeight / 2, width: smallSnapshotWidth, height: smallSnapshotHeight))
            self.frame = CGRect(x: 0, y:  bounds.height / 2 - smallSnapshotHeight/2, width: bounds.width * 0.6, height: bounds.height)
        })
    }
    
    override func layoutSubviews() {
//        homeButton.layer.borderColor = UIColor.black.cgColor
//        homeButton.layer.borderWidth = 1.0
    }
    
}
