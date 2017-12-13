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
    
    var superViewBounds: CGRect!
    var backgroundView: UIImageView!
    var statusBarView: UIView!
    var snapshotView: UIImageView!
    var smallSnapshotWidth: CGFloat!
    var smallSnapshotHeight: CGFloat!
    var menuOutsideButton: UIButton!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setInitialPosition(superViewBounds bounds: CGRect) {
        superViewBounds = bounds
        
        smallSnapshotWidth = bounds.width * 0.4
        smallSnapshotHeight = bounds.height * 0.4

        self.frame = CGRect(x: -bounds.width, y: bounds.height / 2 - bounds.height * 0.4 / 2, width: bounds.width * 0.6, height: bounds.height)
    }
    
    func makeViews(superView: UIView) -> (UIImageView, UIView, UIImageView, UIButton) {
        
        // Make Deep Background
        backgroundView = UIImageView(frame: superView.frame)
        backgroundView.image = #imageLiteral(resourceName: "DeepBackground")
        backgroundView.isOpaque = true
        
        // Make Status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let statusBarRect = CGRect(x: 0, y: 0, width: superView.frame.width, height: statusBarHeight)

        statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = UIColor.white
        statusBarView.isOpaque = true
        
        // Make Snapshot
        UIGraphicsBeginImageContext(superView.frame.size)
        superView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        snapshotView = UIImageView(frame: superView.frame)
        snapshotView.image = image

        // Clickable outside area
        menuOutsideButton = UIButton(frame: CGRect(x: self.frame.width, y: 0, width: superViewBounds.width, height: superViewBounds.height))
        menuOutsideButton.backgroundColor = nil
        
        return (backgroundView, statusBarView, snapshotView, menuOutsideButton)
    }

    func animateIn() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.snapshotView.frame = (CGRect(x: self.superViewBounds.width - self.smallSnapshotWidth / 2, y: self.superViewBounds.height / 2 - self.smallSnapshotHeight / 2, width: self.smallSnapshotWidth, height: self.smallSnapshotHeight))
            self.frame = CGRect(x: 0, y:  self.superViewBounds.height / 2 - self.smallSnapshotHeight/2, width: self.superViewBounds.width * 0.6, height: self.superViewBounds.height)
        })
    }
    
    func closeMenu() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuOutsideButton.alpha = 0.1
            self.frame = CGRect(x: -self.superViewBounds.width, y: self.superViewBounds.height / 2 - self.smallSnapshotHeight/2, width: self.superViewBounds.width * 100, height: self.superViewBounds.height)
            self.backgroundView.frame = CGRect(x: -self.superViewBounds.width, y: 0, width: self.superViewBounds.width * 4, height: self.superViewBounds.height)
            self.snapshotView.frame = self.superViewBounds
        }) { (finished) in
            
            //TODO: - remove statusBarView
            self.snapshotView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.menuOutsideButton.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
//        homeButton.layer.borderColor = UIColor.black.cgColor
//        homeButton.layer.borderWidth = 1.0
    }
    
}
