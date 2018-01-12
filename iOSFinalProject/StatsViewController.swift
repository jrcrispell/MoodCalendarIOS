//
//  StatsViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 1/5/18.
//  Copyright © 2018 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class StatsViewController: UIViewController {
    
    @IBOutlet weak var daysCount: UILabel!
    @IBOutlet weak var activitiesCount: UILabel!
    @IBOutlet weak var hoursCount: UILabel!
    @IBOutlet weak var moodAverage: UILabel!
    var oldSnapshot: UIImage!
    
    var achievements: Achievements!


    
    override func viewDidLoad() {
        super.viewDidLoad()


            self.daysCount.text = achievements.daysLogged.description
            self.activitiesCount.text = achievements.moodScores.count.description
            self.hoursCount.text = String(format: "%.2f", achievements.hoursLogged)
            let moodScoreAverage = Double(achievements.moodScoreSum) / Double(achievements.moodScores.count)
            self.moodAverage.text = String(format: "%.2f", moodScoreAverage)
        
            self.daysCount.text = achievements.daysLogged.description
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
