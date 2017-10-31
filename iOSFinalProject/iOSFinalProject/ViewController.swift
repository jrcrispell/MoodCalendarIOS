//
//  ViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 9/27/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Date data
    var displayedDate = Date()

    // Header
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var backArrowButton: UIButton!
    
    @IBOutlet weak var forwardArrowButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set date
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: displayedDate)
        dateButton.setTitle(dateString, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

