//
//  ExpCard.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/8/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//


import UIKit

class ExpCard: UIView {
    
    @IBOutlet weak var expCardView: UIView!
    @IBOutlet weak var explanationView: UIView!
    
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var emptyExpBar: UIView!
    
    @IBOutlet weak var arrowView: UIView!
    
    @IBOutlet weak var earnedExpWidth: NSLayoutConstraint!
    
    
    override func layoutSubviews() {
        
        let selfBounds = self.layer.bounds
        
        self.layer.shouldRasterize = true
        self.layer.shadowOpacity =  1
        self.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        
        shadowView.layer.shadowPath = UIBezierPath(rect: CGRect(x: selfBounds.minX, y: selfBounds.minY, width: selfBounds.width + 20, height: selfBounds.height + 20)).cgPath
        
        shadowView.layer.shouldRasterize = true
        
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 10, height: 10)
        shadowView.layer.opacity = 0.2
        
        let shadowBounds = shadowView.bounds
        shadowView.layer.shadowPath = UIBezierPath(rect: CGRect(x: shadowBounds.minX, y: shadowBounds.minY, width: shadowBounds.width + 20, height: shadowBounds.height + 20)).cgPath
        shadowView.backgroundColor = UIColor.black
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = shadowView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shadowView.addSubview(blurEffectView)
        
        

//        
//        expCardView.layer.shouldRasterize = true
//
//        expCardView.layer.shadowOpacity = 1
//        expCardView.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        
    }
    

    public func changeExpWidth(percent: CGFloat) {
        
        earnedExpWidth.constant = (percent * emptyExpBar.frame.width)
        
    }
}
