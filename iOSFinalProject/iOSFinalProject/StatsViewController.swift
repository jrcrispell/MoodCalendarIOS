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


    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let userRef = ref.child(user!.uid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            var daysLogged = 0
            var moodScores: [Int] = []
            var moodScoreSum = 0
            var hoursLogged = 0.0
            
            for day in daysArray {
                if day.key == "Achievements" || day.key == "Experience" {continue}
                else {
                    daysLogged += 1
                    guard let activitiesArray = daysArray[day.key] as? [String:Any] else {return}
                    print(activitiesArray.description)
                    for activity in activitiesArray {
                        guard let valuesArray = activitiesArray[activity.key] as? [String:Any],
                        let moodScore = valuesArray["moodScore"] as? Int,
                        let startTime = valuesArray["startTime"] as? Double,
                        let endTime = valuesArray["endTime"] as? Double else {return}
                        hoursLogged += endTime - startTime
                        moodScores.append(moodScore)
                        moodScoreSum += moodScore
                    }
                }
            }
            self.daysCount.text = daysLogged.description
            self.activitiesCount.text = moodScores.count.description
            self.hoursCount.text = String(format: "%.2f", hoursLogged)
            let moodScoreAverage = Double(moodScoreSum) / Double(moodScores.count)
            self.moodAverage.text = String(format: "%.2f", moodScoreAverage)
            
            
            

            
//            for day in daysArray {
//                if day.key == "Achievements" || day.key == "Experience" {continue}
//                else {
//                    daysLogged += 1
//                    let dayRef = userRef.child(day.key)
//                    dayRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                        guard let activityArray = snapshot.value as? [String:Any] else {return}
//
//
//                    })
//                }
//            }
            self.daysCount.text = daysLogged.description
        }
        
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
