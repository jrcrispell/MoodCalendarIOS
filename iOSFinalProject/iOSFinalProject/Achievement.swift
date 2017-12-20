//
//  Achievement.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/17/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import UIKit

protocol EXPShowing {
    func showExpCard(expCard: ExpCard)
    func getView() -> UIView
}

class Achievements: NSObject {
    
    var expShower: EXPShowing!
    
    init(viewController: UIViewController) {
        
        if viewController is EXPShowing {
            self.expShower = viewController as! EXPShowing
        }
        super.init()

    }
    
    func check() {
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let todaysDate = Date()
        let todaysDateRef = ref.child(user!.uid).child(g_dateFormatter.string(from: todaysDate))
        
        let achievementsRef = ref.child(user!.uid).child("Achievements")
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Bool] else {
                return
            }
            
            for achievement in achievementsDict {
                if achievement.key == "firstActivity" && achievement.value == false {
                    self.checkFirstActivity()
                }
                print(achievement.key + " - " + achievement.value.description)
            }

        }
    }
    
    func animateExp(achievementsEarned: [String:Int]) {
        print(achievementsEarned.debugDescription)
        
        let view = expShower.getView()
        
        let xibViews = Bundle.main.loadNibNamed("ExpCard", owner: self, options: nil)

        let expCard = xibViews?.first as! ExpCard
        expCard.earnedExpWidth.constant = 0
        expCard.frame = CGRect(x: view.bounds.width * 0.15, y: view.bounds.height - 140, width: view.bounds.width * 0.7, height: 170)
        expShower.showExpCard(expCard: expCard)
    }
    
    func checkFirstActivity() {
        
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let userRef = ref.child(user!.uid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            var shouldBreak = false
            
            //TODO: low pri = optimize (don't check every day regardless of outcome)
            for day in daysArray {
                if day.key == "Achievements" || day.key == "Experience" {continue}
                else {
                    let dayRef = userRef.child(day.key)
                    dayRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let activityArray = snapshot.value as? [String:Any] else {return}
                        if activityArray.count > 0 {
                            print("WE HAVE AN ACTIVITY WAHOOOOOOO")
                            userRef.child("Achievements").child("firstActivity").setValue(true)
                            self.animateExp(achievementsEarned: ["firstActivity":60])
                            shouldBreak = true
                            return
                        }
                    })
                }
                if (shouldBreak) {
                    print("Oops, I bwoke it")
                    break
                }
            }
        }
    }
}
