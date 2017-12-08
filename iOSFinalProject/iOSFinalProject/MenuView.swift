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
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//
//    private func commonInit() {
//
//    }
    
    override func layoutSubviews() {
//        homeButton.layer.borderColor = UIColor.black.cgColor
//        homeButton.layer.borderWidth = 1.0
    }
    
}
