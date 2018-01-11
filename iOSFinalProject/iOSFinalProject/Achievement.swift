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
    var currentlyAnimating: Bool { get }
    func showExpCard(alreadyVisible: Bool)
    func getView() -> UIView
    func animateExpGain()
    func resolveAnimations()
    func showOnboarding()
    func showTip(number: Int)
}

class Achievements: NSObject {
    
    var xibViews: [Any]? = nil
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    var expCardAnimations: [ExpCardAnimation] = []
    
    var expShower: EXPShowing!
    
    var earnedExperience = 0
    
    var expCard: ExpCard?
    
    var expCardAdded = false
    
    var newAchievements: [String:Int] = [:]
    
    var expCardVisible = false
    
    let userRef: DatabaseReference!
    let achievementsRef: DatabaseReference!
    
    var preventOverflow = false
    
    var daysLogged = 0
    var moodScores: [Int] = []
    var moodScoreSum = 0
    var hoursLogged = 0.0

    
    
    init(viewController: UIViewController) {
        
        userRef = ref.child(user!.uid)
        achievementsRef = userRef.child("Achievements")
        super.init()

        if viewController is EXPShowing {
            self.expShower = viewController as! EXPShowing
            let view = expShower.getView()
            
            if xibViews == nil {
                xibViews = Bundle.main.loadNibNamed("ExpCard", owner: self, options: nil)
            }
            if expCard == nil {
                expCard = xibViews?.first as? ExpCard
                expCard!.earnedExpWidth.constant = 0
                expCard!.frame = CGRect(x: view.bounds.width * 0.15, y: view.bounds.height - 140, width: view.bounds.width * 0.7, height: 170)
            }
        }
        
    }
    
    func createAchievementsDict() {
        self.achievementsRef.child("Logged First Activity").setValue(false)
        self.achievementsRef.child("Used Drag Resize").setValue(false)
        self.achievementsRef.child("Earned Experience").setValue(0)
        self.achievementsRef.child("Used Quick Log").setValue(false)
        self.achievementsRef.child("Rated Application").setValue(false)
        self.achievementsRef.child("Viewed Charts").setValue(false)
        self.achievementsRef.child("Used Date Picker").setValue(false)
        self.achievementsRef.child("Activity Count").setValue(0)
        self.achievementsRef.child("Hour Count").setValue(0.0)
    }
    
    func check() {
        
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Any] else {
                if !self.preventOverflow {
                self.createAchievementsDict()
                self.check()
                self.preventOverflow = true
                }
                return
            }
            
            var checkFirst = false
            var checkDate = false
            var activityCount = 0
            var hourCount = 0.0
            
            for achievement in achievementsDict {
                if achievement.key == "Logged First Activity" && (achievement.value as! Bool) == false {
                    checkFirst = true
                }
                else if achievement.key == "Earned Experience" {
                    self.earnedExperience = achievement.value as! Int
                }
                else if achievement.key == "Activity Count" {
                    activityCount = achievement.value as! Int
                }
                else if achievement.key == "Hour Count" {
                    hourCount = achievement.value as! Double
                }
            }

                self.checkActivities(checkFirst: checkFirst, oldActivityCount: activityCount, oldHourCount: hourCount)
        }
    }
    
    func animateExp() {
        
        if newAchievements.count == 0 {
            return
        }
        
        if expShower != nil {
        expShower.showExpCard(alreadyVisible: expCardVisible)
        expCardVisible = true
        }
    }
    
    func checkActivities(checkFirst: Bool, oldActivityCount: Int, oldHourCount: Double) {
        
        if expShower == nil {
            return
        }
        
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            self.daysLogged = 0
            self.moodScores = []
            self.moodScoreSum = 0
            self.hoursLogged = 0.0
            
            for day in daysArray {
                if day.key == "Achievements" {continue}
                else {
                    self.daysLogged += 1
                    
                    guard let activitiesArray = daysArray[day.key] as? [String:Any] else {return}
                    for activity in activitiesArray {
                        guard let valuesArray = activitiesArray[activity.key] as? [String:Any],
                            let moodScore = valuesArray["moodScore"] as? Int,
                            let startTime = valuesArray["startTime"] as? Double,
                            let endTime = valuesArray["endTime"] as? Double else {return}
                        self.hoursLogged += endTime - startTime
                        self.moodScores.append(moodScore)
                        self.moodScoreSum += moodScore
                    }
                    

                    }
                }
            
            if self.moodScores.count == 0 {
                self.expShower.showOnboarding()
            }
            else if self.moodScores.count < 3 {
                self.expShower.showTip(number: 1)
            }
            else if self.moodScores.count < 5 {
               self.expShower.showTip(number: 2)
            }
            
            // Check for Logged First Activity achievement
            if self.moodScores.count > 0 && checkFirst {
                self.achievementsRef.child("Logged First Activity").setValue(true)
                self.newAchievements["Logged First Activity"] = 50
                self.animateExp()
            }
            
                // Check for new activities
                if self.moodScores.count > oldActivityCount {
                    let newActivities = self.moodScores.count - oldActivityCount
                    if newActivities == 1 {
                        self.newAchievements["Logged Activity"] = 5
                        self.achievementsRef.child("Activity Count").setValue(self.moodScores.count)
                    }
                    else {
                        self.newAchievements["Logged Activities"] = 5 * newActivities
                        self.achievementsRef.child("Activity Count").setValue(self.moodScores.count)
                        
                    }
                    self.animateExp()
                }
            
                if self.hoursLogged > oldHourCount {
                    
                    var roundedHours = (self.hoursLogged * 10).rounded(.toNearestOrAwayFromZero) / 10
                    
                    
                    
                    let newHours = Int(self.hoursLogged - oldHourCount)
                    if newHours == 0 {return}
                    self.newAchievements["Total logged hours: (\(roundedHours)"] = newHours * 5
                    self.achievementsRef.child("Hour Count").setValue(self.hoursLogged)
                    self.animateExp()
                }
            
            }
        
    }
    
    // See if first time using date picker give achievement
    func usedDatePicker() {
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Any] else {return}
            for achievement in achievementsDict {
                if achievement.key == "Used Date Picker" && (achievement.value as! Bool) == false {
                    self.newAchievements["Used Date Picker"] = 60
                    self.achievementsRef.child("Used Date Picker").setValue(true)
                    self.animateExp()
                }
            }
        }
    }
    
    // If first time using date picker give achievement
    func usedClickDragResize() {
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Any] else {return}
            for achievement in achievementsDict {
                if achievement.key == "Used Drag Resize" && (achievement.value as! Bool) == false {
                    self.newAchievements["Used Drag Resize"] = 50
                    self.achievementsRef.child("Used Drag Resize").setValue(true)
                    self.animateExp()
                }
            }
        }
    }
    
    
    
    
    func expRequiredFor(level: Int) -> Int {
        var j = 0
        for i in 0..<level {
            j = j + i*100
        }
        return j
    }
    
    func levelFor(exp: Int) -> Int {
        var j = 0
        for i in 0...20 {
            j = j + i*100
            if j > exp {
                return i
            }
        }
        return 20
    }
    
    
    
    
}
