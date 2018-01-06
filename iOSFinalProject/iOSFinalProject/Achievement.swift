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
    
    
    init(viewController: UIViewController) {
        
        if viewController is EXPShowing {
            self.expShower = viewController as! EXPShowing
        }
        super.init()
        
    }
    
    func check() {
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
            
        let achievementsRef = ref.child(user!.uid).child("Achievements")
        achievementsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let achievementsDict = snapshot.value as? [String:Any] else {
                return
            }
            
            var checkFirst = false
            var checkDate = false
            
            for achievement in achievementsDict {
                if achievement.key == "firstActivity" && (achievement.value as! Bool) == false {
                    checkFirst = true
                }
                else if achievement.key == "usedDatePicker" && (achievement.value as! Bool) == false {
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
        }
        expShower.showExpCard(alreadyVisible: true)


        
    }
    
    func checkFirstActivity() {
        
        
        let userRef = ref.child(user!.uid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let daysArray = snapshot.value as? [String:Any] else {return}
            
            var shouldBreak = false

            for day in daysArray {
                if day.key == "Achievements" || day.key == "Experience" {continue}
                else {
                    let dayRef = userRef.child(day.key)
                    dayRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let activityArray = snapshot.value as? [String:Any] else {return}
                        if activityArray.count > 0 && !shouldBreak {
                            //TODO: Uncomment next line to save to db
                            //userRef.child("Achievements").child("firstActivity").setValue(true)
                            self.newAchievements["firstActivity"] = 250
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
        self.newAchievements["Used date picker"] = 500
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
