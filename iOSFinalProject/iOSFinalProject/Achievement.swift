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
    var animatingExp: Bool { get }
    func showExpCard(expCard: ExpCard, percent: CGFloat)
    func getView() -> UIView
    func animateExpGain(percent: CGFloat, expCard: ExpCard)
}

class Achievements: NSObject {
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    var expShower: EXPShowing!
    
    var earnedExperience = 0
    
    var achievementsEarned: [String:Int] = [:] {
        didSet {
            print("bingo")
            animateExp(achievementsEarned: achievementsEarned)
        }
    }
    
    
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
    
    func animateExp(achievementsEarned: [String:Int]) {
        print(achievementsEarned.debugDescription)
        let keys = Array(achievementsEarned.keys)
        
        let view = expShower.getView()
        
        let xibViews = Bundle.main.loadNibNamed("ExpCard", owner: self, options: nil)
        
        let expCard = xibViews?.first as! ExpCard
        expCard.earnedExpWidth.constant = 0
        expCard.frame = CGRect(x: view.bounds.width * 0.15, y: view.bounds.height - 140, width: view.bounds.width * 0.7, height: 170)
        
        
        //TODO: - Convert from 60 exp to .6 percent
        
        expShower.showExpCard(expCard: expCard, percent: 1.5)
    }
    
    func checkFirstActivity() {
        
        
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
                        if activityArray.count > 0 && !shouldBreak {
                            print("WE HAVE AN ACTIVITY WAHOOOOOOO")
                            userRef.child("Achievements").child("firstActivity").setValue(true)
                            self.achievementsEarned["firstActivity"] = 60
                            //self.animateExp(achievementsEarned: achievementsEarned)
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
        self.achievementsEarned["usedDatePicker"] = 50
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
