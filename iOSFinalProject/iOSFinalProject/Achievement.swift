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
}

class Achievements: NSObject {
    
    var xibViews: [Any]? = nil
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    var expCardAnimations: [ExpCardAnimation] = []
    
    var expShower: EXPShowing!
    
    var earnedExperience = 0
    
    var expCard: ExpCard!
    
    var newAchievements: [String:Int] = [:]
    
    var expCardVisible = false
    
    let userRef: DatabaseReference!
    let achievementsRef: DatabaseReference!
    
    var preventOverflow = false

    
    
    init(viewController: UIViewController) {
        
        userRef = ref.child(user!.uid)
        achievementsRef = userRef.child("Achievements")
        
        if viewController is EXPShowing {
            self.expShower = viewController as! EXPShowing
        }
        super.init()
        
    }
    
    func createAchievementsDict() {
        self.achievementsRef.child("Logged First Activity").setValue(false)
        self.achievementsRef.child("Used Drag Resize").setValue(false)
        self.achievementsRef.child("earnedExperience").setValue(0)
        self.achievementsRef.child("Used Quick Log").setValue(false)
        self.achievementsRef.child("Rated Application").setValue(false)
        self.achievementsRef.child("Viewed Charts").setValue(false)
        self.achievementsRef.child("Used Date Picker").setValue(false)

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
            
            for achievement in achievementsDict {
                if achievement.key == "Logged First Activity" && (achievement.value as! Bool) == false {
                    checkFirst = true
                }
                else if achievement.key == "Used Date Picker" && (achievement.value as! Bool) == false {
                    checkDate = true
                }
                else if achievement.key == "earnedExperience" {
                    self.earnedExperience = achievement.value as! Int
                }
            }
            if checkFirst {
                self.checkFirstActivity()
            }
            if checkDate {
                self.checkDatePicker()
            }
        }
    }
    
    func animateExp() {

        if expShower == nil {
            return
        }
        
        let view = expShower.getView()
        
        if xibViews == nil {
        xibViews = Bundle.main.loadNibNamed("ExpCard", owner: self, options: nil)
        }
        if expCard == nil {
        expCard = xibViews?.first as! ExpCard
        expCard.earnedExpWidth.constant = 0
        expCard.frame = CGRect(x: view.bounds.width * 0.15, y: view.bounds.height - 140, width: view.bounds.width * 0.7, height: 170)
            expShower.showExpCard(alreadyVisible: false)
            expCardVisible = true
        }
        expShower.showExpCard(alreadyVisible: expCardVisible)


        
    }
    
    func checkFirstActivity() {
        
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            var shouldBreak = false

            for day in daysArray {
                if day.key == "Achievements" || day.key == "Experience" {continue}
                else {
                    let dayRef = self.userRef.child(day.key)
                    dayRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let activityArray = snapshot.value as? [String:Any] else {return}
                        if activityArray.count > 0 && !shouldBreak {
                            self.achievementsRef.child("Logged First Activity").setValue(true)
                            self.newAchievements["Logged First Activity"] = 50
                            self.animateExp()
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
    
    func checkDatePicker() {
        self.newAchievements["Used date picker"] = 60
        achievementsRef.child("Used date picker").setValue(true)
        self.animateExp()
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
