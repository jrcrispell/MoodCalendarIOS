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

class Achievements {
    
    static func check() {
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let todaysDate = Date()
        let todaysDateRef = ref.child(user!.uid).child(g_dateFormatter.string(from: todaysDate))
        
        let achievementsRef = ref.child(user!.uid).child("Achievements")
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Bool] else {
                return
            }

            var achievementsEarned: [String:Int] = [:]
            
            for achievement in achievementsDict {
                if achievement.key == "firstActivity" && achievement.value == false {
                    let result = checkFirstActivity()
                    if (result > 0) {
                        achievementsEarned[achievement.key] = 60
                    }
                }
                print(achievement.key + " - " + achievement.value.description)
            }
            
            if achievementsEarned.count > 0 {
                animateExp(achievementsEarned: achievementsEarned)
            }
        }
    }
    
    static func animateExp(achievementsEarned: [String:Int]) {
        print(achievementsEarned.debugDescription)
    }
    
    static func checkFirstActivity() -> Int {
        
        var expEarned = 0
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let userRef = ref.child(user!.uid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            var shouldBreak = false
            
            //TODO: this doesn't return correctly to previous method since it's asynchronous, i think i need to resolve the animateExp here
            for day in daysArray {
                if day.key == "Achievements" || day.key == "Experience" {continue}
                else {
                    let dayRef = userRef.child(day.key)
                    dayRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let activityArray = snapshot.value as? [String:Any] else {return}
                        if activityArray.count > 0 {
                            print("WE HAVE AN ACTIVITY WAHOOOOOOO")
                            expEarned = 60
                            userRef.child("Achievements").child("firstActivity").setValue(true)
                            shouldBreak = true
                            return
                        }
                    })
                }
                if (shouldBreak) {
                    break
                }
            }
        }
        return expEarned
    }
}
