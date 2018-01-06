//
//  StatsViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 1/5/18.
//  Copyright © 2018 Crispell Apps. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet weak var daysCount: UILabel!
    @IBOutlet weak var activitiesCount: UILabel!
    @IBOutlet weak var hoursCount: UILabel!
    @IBOutlet weak var moodAverage: UILabel!
    var oldSnapshot: UIImage!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
