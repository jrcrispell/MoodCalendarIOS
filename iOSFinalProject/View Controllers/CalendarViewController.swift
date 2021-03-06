//
//  ViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 9/27/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.

// Master
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import UserNotifications

import SystemConfiguration

let g_dateFormatter = DateFormatter()

let DEPRESSION_SCREEN_URL = "https://psychcentral.com/quizzes/depquiz.htm";


class CalendarViewController: UIViewController, ViewControllerDelegate, UIPickerViewDelegate, EXPShowing, TipViewShowing
    
{
    func takeDepressionScreen() {
        
        guard let screenURL = URL(string: DEPRESSION_SCREEN_URL) else {return}
        
        // Take screen alert
        let screenAlert = UIAlertController(title: "Depression Screen", message: "It's time to take a depression screen! Woo-hoo!", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (alert) in
            UIApplication.shared.open(screenURL, options: [:], completionHandler: { (finished) in
                self.handleScreenResult()
            })
        }
        screenAlert.addAction(okButton)
        present(screenAlert, animated: true) {
            
        }
    }
    func handleScreenResult() {
        let resultAlert = UIAlertController(title: "Enter result", message: "Please enter the score you received", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let okButton = UIAlertAction(title: "OK", style: .default) { (alert) in
            //Do nothing
            let textField = resultAlert.textFields![0] as UITextField
            guard let depressionScore =  Int(textField.text!) else {return}
            self.achievements.recordDepressionScore(depressionScore: depressionScore)

        }
        resultAlert.addTextField { (textField) in
            textField.placeholder = "Enter score here"
            textField.keyboardType = .numberPad
        }
        resultAlert.addAction(cancelButton)
        resultAlert.addAction(okButton)
        present(resultAlert, animated: true, completion: nil)
    }
    
    func removeTipView() {
        closedTipView = true
    }
    
    func getView() -> UIView {
        return self.view
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //TODO: - known bugs: switching between activities in editing mode, don't allow dragging past the end of the calendar (above 12 AM will go to 11 PM)
    //TODO: - known bug: click-drag resizing doesn't give exp
    
    // Date data
    var displayedDate = Date()
    var dateString = ""
    let calendar = Calendar.current
    
    // Draggable handles (for long-click drag resizing)
    var topHandle: UIImageView?
    var botHandle: UIImageView?
    // Prevent overlap with other activities
    var precedingEndTime = 0.0
    var followingStartTime = 24.0
    
    // Outlets
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var datePickerTop: NSLayoutConstraint!
    @IBOutlet weak var hamburger: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scrollViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    // Onboarding
    @IBOutlet weak var dateArrows: UIImageView!
    @IBOutlet weak var dateOnboardingText: UILabel!
    @IBOutlet weak var upTapArrow: UIImageView!
    @IBOutlet weak var downTapArrow: UIImageView!
    @IBOutlet weak var tapOnboardingText: UITextView!
    
    @IBOutlet weak var navigationBar: UIView!
    
    // Firebase
    let ref = Database.database().reference()
    var displayedDateRef: DatabaseReference!
    var user: User!
    
    // Menu
    var menuView: MenuView!
    var menuOutsideButton: UIButton!
    var snapshotView: UIImageView!
    var backgroundView: UIImageView!
    var smallSnapshotWidth: CGFloat!
    var smallSnapshotHeight: CGFloat!
    var oldSnapshotView: UIImageView!
    var oldSnapshot: UIImage?

    
    @IBOutlet weak var backArrowButton: UIButton!
    
    // Exp
    var displayLevelUp = false
    var expCardTimer: Timer? = nil
    
    var tipView: TipView?
    var closedTipView = false
    var tipShown = false
    var quicklogTipShown = false
    var defaultTipShown = false
    
    // Misc
    var daysActivities = [CalendarActivity]()
    var editingActivity: CalendarActivity!
    var precedingActivity: CalendarActivity?
    var sendStartTime: Double = 0
    var sendExactStartTime: Double = 0
    var editMode = false
    let userDefaults = UserDefaults.standard
    var datePickerVisibile = false
    var bounds:CGRect!
    
    var achievements: Achievements!
    
    var currentlyAnimating: Bool = false
    
    
    //MARK: - ViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        achievements = Achievements(viewController: self)
        
        backArrowButton.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        datePicker.date = displayedDate
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        self.view.backgroundColor = UIColor.white
        
        // Set date
        g_dateFormatter.dateFormat = "MMM d, yyyy"
        updateDate()
        
        
        
        // Authorized Firebase user
        user = Auth.auth().currentUser
        
        // Set delegate
        calendarView.viewControllerDelegate = self
        
        // Set up user preferences
        
        let defaults: [String : Any] = ["notifications_start" : 8, "notifications_end" : 22]
        UserDefaults.standard.register(defaults: defaults)
        
        hamburger.setImage(Utils.defaultMenuImage(), for: UIControlState.normal)
        
        //createExampleData()
    }
    
    func createExampleData() {
        
        var date = Date(timeIntervalSinceNow: -180 * Utils.secondsInADay)
        
        for _ in 0...180 {
            date = date.addingTimeInterval(Utils.secondsInADay)
            for i in 0...23 {
                let rand = arc4random_uniform(11)
                Utils.saveNewActivity(startTime: Double(i), endTime: Double(i+1), eventDescription: "Randomized Activity", moodScore: Int(rand), dateKey: g_dateFormatter.string(from: date), viewController: self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if oldSnapshot != nil {
        UIView.transition(from: oldSnapshotView, to: snapshotView, duration: 0.3, options: .transitionFlipFromLeft) { (finished) in
            self.menuView.closeAfterFlip()
            self.oldSnapshot = nil
        }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDate()
        tipView = nil
        editingActivity = nil
        loadEvents()
        makeNextNotification(incomingDate: Date())
        achievements.check()
        precedingEndTime = 0.0
        followingStartTime = 24.0
        hamburger.isHidden = false
        
        
        if oldSnapshot != nil {
            animateFromMenu()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "toLogger" {
            guard let loggerView = segue.destination as? LoggerViewController else {return}
            if editingActivity != nil {
                loggerView.editingActivity = editingActivity
            }
            // Making new activity
            loggerView.displayedDate = displayedDate
            loggerView.incomingStartTime = sendStartTime
            loggerView.incomingEndTime = sendStartTime + 1
            loggerView.incomingExactStartTime = self.sendExactStartTime
            if self.precedingActivity != nil {
                loggerView.precedingEndTime = self.precedingActivity!.endTime
            }
            
        }
        else if segue.identifier == "toCharts" {
            guard let chartsView = segue.destination as? MyChartsViewController else {return}
            chartsView.oldSnapshot = menuView.snapshotView.image
            chartsView.achievements = self.achievements
        }
        else if segue.identifier == "toStats" {
            guard let statsView = segue.destination as? StatsViewController else {return}
            statsView.oldSnapshot = menuView.snapshotView.image
            statsView.achievements = achievements
        }
    }
    
    //MARK: Menu
    
    func makeMenu() {
        
        let xibViews = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
        
        menuView = xibViews?.first as! MenuView
        
        menuView.setInitialPosition(superViewBounds: view.bounds)
        
        let backgroundViews = menuView.makeViews(superView: view)
        snapshotView = backgroundViews.2
        
        self.view.addSubview(backgroundViews.0)
        self.view.addSubview(backgroundViews.1)
        self.view.addSubview(backgroundViews.2)
        self.view.addSubview(backgroundViews.3)
        self.view.addSubview(menuView)
        
        // Set up buttons
        menuView.homeButton.addTarget(self, action: #selector(handleHome(_:)), for: .touchUpInside)
        menuView.homeButton.alpha = 1.0
        menuView.homeIcon.alpha = 1.0
        menuView.dataVisButton.addTarget(self, action: #selector(handleCharts(_:)), for: .touchUpInside)
        menuView.settingsButton.addTarget(self, action: #selector(handleSettings(_:)), for: .touchUpInside)
        menuView.logOutButton.addTarget(self, action: #selector(handleLogOut(_: )), for: .touchUpInside)
        menuView.menuOutsideButton.addTarget(self, action: #selector(handleMenuOutsideButtonSend(_: ) ), for: .touchUpInside)
        
        hamburger.isHidden = true

        menuView.animateIn()
    }
    
    func closeMenu() {
        menuView.closeMenu()
        hamburger.isHidden = false
    }
    
    //MARK: WORKING HERE
    
    func showExpCard(alreadyVisible: Bool, newAchievements: [String:Int]) {
                
        if !achievements.expCardAdded {
            self.view.addSubview(achievements.expCard!)
            self.view.layoutIfNeeded()
            achievements.expCardAdded = true
        }
        
        print("Unhiding expcard")
        achievements.expCard?.isHidden = false
        achievements.expCardVisible = true
        
        animateExpGain(newAchievements: newAchievements)
        
    }
    
    func animateFromMenu() {
        let xibViews = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
        menuView = xibViews?.first as! MenuView
        
        // Set up menu to close
        let views = menuView.makeViews(superView: view)
        menuView.homeIcon.alpha = 1.0
        menuView.homeButton.alpha = 1.0
        
        menuView.frame = CGRect(x: 0, y: view.bounds.height / 2 - menuView.smallSnapshotHeight / 2, width: view.bounds.width * 0.6, height: view.bounds.height)
        
        view.addSubview(views.0)
        view.addSubview(views.1)
        view.addSubview(views.3)
        view.addSubview(menuView)
        
        snapshotView = views.2
        
        oldSnapshotView = UIImageView(image: oldSnapshot)
        
        menuView.shrinkSnapshot(snapshotView: snapshotView, superViewBounds: view.bounds)
        
        menuView.shrinkSnapshot(snapshotView: oldSnapshotView, superViewBounds: view.bounds)
        
        let containerView = UIView(frame: snapshotView.frame)
        snapshotView.frame = CGRect(x: 0, y: 0, width: snapshotView.frame.width, height: snapshotView.frame.height)
        oldSnapshotView.frame = snapshotView.frame
        
        containerView.addSubview(snapshotView)
        containerView.addSubview(oldSnapshotView)
        menuView.containerView = containerView
        view.addSubview(containerView)
        
    }
    
    func levelUp() {
        
        displayLevelUp = false
        
        let xibViews = Bundle.main.loadNibNamed("LevelUp", owner: self, options: nil)
        
        let levelUp = xibViews?.first as! UIView
        
        levelUp.frame = CGRect(x: view.bounds.width * 0.1, y: view.bounds.height/1.7, width: view.bounds.width * 0.9, height: 80)
        levelUp.alpha = 0
        view.addSubview(levelUp)
        
        UIView.animate(withDuration: 3, animations: {
            levelUp.alpha = 1
        }) { (finished) in
            
            let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                levelUp.removeFromSuperview()

            })
        }
    }
    
    func showOnboarding() {
        // Date onboarding
        dateArrows.isHidden = false
        dateOnboardingText.isHidden = false
        
        // Tap onboarding
        tapOnboardingText.isHidden = false
        upTapArrow.isHidden = false
        downTapArrow.isHidden = false
    }
    
    func hideOnboarding() {
        // Date onboarding
        dateArrows.isHidden = true
        dateOnboardingText.isHidden = true
        
        // Tap onboarding
        tapOnboardingText.isHidden = true
        upTapArrow.isHidden = true
        downTapArrow.isHidden = true
    }
    

    func showTip(number: Int) {
        
         //Prevent the same tip from showing over and over
        if tipShown{
            return
        }
        if number != 2 {
            if defaultTipShown || closedTipView {
                return
            }
        defaultTipShown = true
        }
        else {
            if (quicklogTipShown) {
                return
            }
            quicklogTipShown = true
        }

        let xibViews = Bundle.main.loadNibNamed("Tip", owner: self, options: nil)

        tipView = xibViews?.first as? TipView
        tipView!.frame = CGRect(x: view.bounds.width * 0.15, y: navigationBar.frame.maxY, width: view.bounds.width * 0.7, height: 86)
        tipView!.tipShower = self
        closedTipView =  false
        if number == 2 {
            tipView!.tipLine1.text = "Try pressing forcefully"
            tipView!.tipLine2.text = "on notifications to use QuickLog"
        }
        view.addSubview(tipView!)

    }
    
    
    
    
    
    func animateExpGain(newAchievements: [String:Int]) {
        
        if newAchievements.count == 0 {
            return
        }
        print("Creating animations")
        
        let earnedExperience = achievements.earnedExperience
        var currentLevel = achievements.levelFor(exp: earnedExperience)
        let expForNextLevel = achievements.expRequiredFor(level: currentLevel + 1)
        
        let expLeft = expForNextLevel - earnedExperience
        
        let expBetweenLevels = achievements.expRequiredFor(level: currentLevel + 1) - achievements.expRequiredFor(level: currentLevel)
        let progressToLevel = expBetweenLevels - expLeft
        var expPercentage = CGFloat(progressToLevel)/CGFloat(expBetweenLevels)
        
        let newAchievementsCopy = newAchievements
        
        let keys = Array(newAchievementsCopy.keys)
        for key in keys {
            

            let achievementExp = newAchievementsCopy[key]!
            achievements.earnedExperience += achievementExp
            achievements.achievementsRef.child("Earned Experience").setValue(achievements.earnedExperience)
            
            // This is run if you're going to be gaining a level
            if achievementExp >= expLeft {
                displayLevelUp = true
                let destinationLevel = achievements.levelFor(exp: earnedExperience + achievementExp)
                let levelsGained = destinationLevel - currentLevel
                
                let newEarnedExperience = earnedExperience + achievementExp
                let newExpLeft = achievements.expRequiredFor(level: destinationLevel + 1) - newEarnedExperience
                let expBetweenFinalLevels = achievements.expRequiredFor(level: destinationLevel + 1) - achievements.expRequiredFor(level: destinationLevel)
                let newProgressToLevel = expBetweenFinalLevels - newExpLeft
                let newExpPercentage = CGFloat(newProgressToLevel)/CGFloat(expBetweenFinalLevels)
                
                for index in 0...levelsGained {
                    
                    // Gaining level animation
                    if index < levelsGained {
                        achievements.expCardAnimations.append(ExpCardAnimation(earnedExp: newEarnedExperience, expLeft: 0, gaugeStartPercent: expPercentage, gaugeEndPercent: 1.0, currentLevel: currentLevel, nextLevel: expForNextLevel, explanationExp: achievementExp, explanationAchievement: key))
                        currentLevel += 1
                        expPercentage = 0
                    }
                        
                        // final, non level gaining animation
                    else {
                        achievements.expCardAnimations.append(ExpCardAnimation(earnedExp: newEarnedExperience, expLeft: newExpLeft, gaugeStartPercent: expPercentage, gaugeEndPercent: newExpPercentage, currentLevel: currentLevel, nextLevel: expForNextLevel, explanationExp: achievementExp, explanationAchievement: key))
                    }
                    
                }
                
            }
                
                // Gaining exp without gaining a level
            else {
                
                let newEarnedExperience = earnedExperience + achievementExp
                
                let newExpLeft = expForNextLevel - newEarnedExperience
                let newProgressToLevel = expBetweenLevels - newExpLeft
                let newExpPercentage = CGFloat(newProgressToLevel)/CGFloat(expBetweenLevels)
                achievements.expCardAnimations.append(ExpCardAnimation(earnedExp: newEarnedExperience, expLeft: newExpLeft, gaugeStartPercent: expPercentage, gaugeEndPercent: newExpPercentage, currentLevel: currentLevel, nextLevel: expForNextLevel, explanationExp: achievementExp, explanationAchievement: key))
                print("added non level gaining animation")
                
            }
            // Remove from original array
            achievements.newAchievements[key] = nil
        }
        print("about to call resolve")
        resolveAnimations()
    }
    
    func resolveAnimations() {
        if (currentlyAnimating) {
            print("Resolve was animating, returning")
            return
        }
        
        print("Resolve was not animating")
        guard let expCard = achievements.expCard else {return}
        
        if achievements.expCardAnimations.count > 0 {
            currentlyAnimating = true
            
            let nextAnimation = achievements.expCardAnimations[0]
            
            print("Preparing next animation: \(nextAnimation.explanationAchievement)")
            expCard.earnedExpPoints.text = nextAnimation.earnedExp.description + " exp points"
            expCard.currentLevel.text = "Level " + nextAnimation.currentLevel.description
            expCard.nextLevel.text = "Level " + (nextAnimation.currentLevel + 1).description
            expCard.expLeft.text = nextAnimation.expLeft.description + " exp to"
            expCard.earnedExpWidth.constant = nextAnimation.gaugeStartPercent * expCard.emptyExpBar.frame.width
            
            expCard.explanationEarnedExp.text = "You earned " + nextAnimation.explanationExp.description + " exp for:"
            expCard.explanationEarnedAchievement.text = nextAnimation.explanationAchievement
            
            
            view.layoutIfNeeded()
            expCard.earnedExpWidth.constant = nextAnimation.gaugeEndPercent * expCard.emptyExpBar.frame.width
            
            achievements.expCardAnimations.remove(at: 0)
            print("About to animate")
            UIView.animate(withDuration: TimeInterval(nextAnimation.duration), animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                print("animation done")
                if (self.displayLevelUp) {
                    self.levelUp()
                }
                self.currentlyAnimating = false
                print("About to recurse resolve")
                self.resolveAnimations()
                
            })
        }
        else {
            print("no animations left")
            if expCardTimer != nil {
                expCardTimer?.invalidate()
                expCardTimer = nil
            }
            
            expCardTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (timer) in
                //TODO: Animate out
                expCard.isHidden = true
                self.achievements.expCardVisible = false
                self.currentlyAnimating = false
            })
            
            
        }
    }
    
    func animateConstraints() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    func showDatePicker() {
        // Hide date onboarding
        dateArrows.isHidden = true
        dateOnboardingText.isHidden = true
        
        datePickerTop.constant = 8
        scrollViewTopSpace.constant = 8
        datePickerVisibile = true
        animateConstraints()
        achievements.usedDatePicker()
    }
    
    func hideDatePicker() {
        datePickerTop.constant = -308
        scrollViewTopSpace.constant = 140
        datePickerVisibile = false
        animateConstraints()
    }
    
    func loadEvents() {
        
        self.activityIndicator.startAnimating()
        
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not load events."), animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            return
        }
        
        
        displayedDateRef = ref.child(user.uid).child(dateString)
        displayedDateRef.observeSingleEvent(of: .value, with:{ (snapshot) in
            self.daysActivities = []
            
            guard let activityDictionary = snapshot.value as? [String:Any] else {
                print("No existing activities")
                self.calendarView.makeActivityDrawables()
                self.calendarView.setNeedsDisplay()
                self.activityIndicator.stopAnimating()
                return
            }
            let activityIds = Array(activityDictionary.keys)
            for id in activityIds {
                guard let values = activityDictionary[id] as? [String:Any],
                    let startTime = values["startTime"] as? Double,
                    let endTime = values["endTime"] as? Double,
                    let activityDescription = values["activityDescription"] as? String,
                    let moodScore = values["moodScore"] as? Double else {continue}
                
                self.daysActivities.append(CalendarActivity(databaseID: id, startTime: startTime, endTime: endTime, activityDescription: activityDescription, moodScore: Int(moodScore)))
            }
            self.calendarView.makeActivityDrawables()
            self.calendarView.setNeedsDisplay()
            self.activityIndicator.stopAnimating()
            
        })
        return
    }
    
    func updateDate() {
        datePicker.date = displayedDate
        dateString = g_dateFormatter.string(from: displayedDate)
        
        // Check to see if current day, if so add current time line to calendar view
        if g_dateFormatter.string(from: Date()) == dateString {
            calendarView.today = true
        }
        else {
            calendarView.today = false
        }
        dateButton.setTitle(dateString, for: .normal)
    }
    
    func getDaysActivities() -> [CalendarActivity] {
        return daysActivities
    }
    
    func editActivity(activity: CalendarActivity) {
        editMode = true
        
        
        topHandle = UIImageView(image: #imageLiteral(resourceName: "whiteHandle2"))
        botHandle = UIImageView(image: #imageLiteral(resourceName: "whiteHandle2"))
        
        
        // Gesture recognizers
        let topGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDraggableHandle(_:)))
        let botGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDraggableHandle(_:)))
        
        topHandle!.addGestureRecognizer(topGestureRecognizer)
        
        topHandle!.tag = 2
        let handleHalfWidth = Double(topHandle!.frame.width) / 2
        let rectangleCenterX = Double(calendarView.center.x) + g_lineStartX/2 - handleHalfWidth
        topHandle!.center = CGPoint(x: rectangleCenterX, y: Utils.converHourToY(time: activity.startTime))
        
        botHandle!.tag = 3
        botHandle!.center = CGPoint(x: rectangleCenterX, y: Utils.converHourToY(time: activity.endTime))
        botHandle!.addGestureRecognizer(botGestureRecognizer)
        
        topHandle!.isUserInteractionEnabled = true
        botHandle!.isUserInteractionEnabled = true
        
        calendarView.addSubview(topHandle!)
        calendarView.addSubview(botHandle!)
    }
    
    func endEditMode() {
        editMode = false
        editingActivity = nil
         //Remove draggable lines
        for view in calendarView.subviews {
            if view.tag == 2 || view.tag == 3 {
                view.removeFromSuperview()
            }
        }
        achievements.check()
        achievements.usedClickDragResize()
    }
    
    //MARK: Menu Selectors
    @objc func handleLogOut(_ sender: UIButton){
        closeMenu()
        logOutTapped(sender)
    }
    
    @objc func handleSettings(_ sender: UIButton){
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        closeMenu()
        
    }
    
    @objc func handleCharts(_ sender: UIButton){
        closeMenu()
        performSegue(withIdentifier: "toCharts", sender: sender)
        //performSegue(withIdentifier: "toStats", sender: sender)
    }
    
    @objc func handleHome(_ sender: UIButton){
        closeMenu()
    }

    
    @objc func handleMenuOutsideButtonSend(_ sender: UIButton){
        closeMenu()
    }
    
    //MARK: - IBActions
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not change days."), animated: true, completion: nil)
            return
        }
        
        displayedDate = sender.date
        updateDate()
        loadEvents()
    }
    
    @IBAction func dateTapped(_ sender: Any) {
        
        if !datePickerVisibile {
            showDatePicker()
        }
        else {
            hideDatePicker()
        }
    }
    
    @IBAction func hamburgerTapped(_ sender: Any) {
        if (datePickerVisibile) {
            datePickerTop.constant = -308
            scrollViewTopSpace.constant = 150
            datePickerVisibile = false
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                self.makeMenu()
            })
        }
        else {
            makeMenu()
        }
    }
    
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not change days."), animated: true, completion: nil)
            return
        }
        
        let calendar = Calendar.current
        // Back arrow
        if sender.tag == 0 {
            displayedDate = calendar.date(byAdding: .day, value: -1, to: displayedDate)!
        }
            
            // Forward arrow
        else {
            displayedDate = calendar.date(byAdding: .day, value: 1, to: displayedDate)!
        }
        updateDate()
        loadEvents()
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            self.present(Utils.makeSimpleAlert(title: "Sign out error", message: error.localizedDescription), animated: true, completion: nil)
        }
    }
    
    
    @IBAction func calendarViewTapped(_ sender: UITapGestureRecognizer) {
        
        if (editMode) {
            endEditMode()
            return
        }
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not complete request."), animated: true, completion: nil)
            return
        }
        
        let point = sender.location(in: calendarView)
        if let activity = calendarView.getSelectedActivity(location: point) {
            editingActivity = activity
        }
        
        self.precedingActivity = nil
        // Get preceding activity for loggerview time picker logic
        sendExactStartTime = Utils.convertYToHour(point.y)
        if (editingActivity == nil) {
            
            var precedingEndTime = 0.0
            
            for activity in self.daysActivities {
                if activity.endTime < self.sendExactStartTime && activity.endTime > precedingEndTime {
                    self.precedingActivity = activity
                    precedingEndTime = activity.endTime
                }
            }
        }
        
        // Calculate start hour where user clicked, will be sent in prepare function
        sendStartTime = Double(Int(Utils.convertYToHour(point.y)))
        
        performSegue(withIdentifier: "toLogger", sender: sender)
    }
    
    @IBAction func calendarViewLongPress(_ sender: UILongPressGestureRecognizer) {
        
        // Only act on the "release" touch
        if sender.state.rawValue != 3 {return}
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, can not edit activities"), animated: true, completion: nil)
            return
        }
        
        
        let timeTapped = Utils.convertYToHour(sender.location(in: calendarView).y)
        
        var activityTouched = false
        
        
        if editingActivity != nil {
            editingActivity = nil
            endEditMode()
        }
        
        for activity in daysActivities {
            if timeTapped >= activity.startTime && timeTapped <= activity.endTime {
                editActivity(activity: activity)
                activityTouched = true
                editingActivity = activity
            }
        }
            if (!activityTouched) || editingActivity == nil {
                endEditMode()
                return
            }
        
        precedingEndTime = 0.0
        followingStartTime = 24.0
        
        for activity in self.daysActivities {
            if activity.endTime <= editingActivity.startTime && activity.endTime >= precedingEndTime {
                precedingEndTime = activity.endTime
                //print("activity checker: endTime = \(activity.endTime)")
            }
            if activity.startTime >= editingActivity.endTime && activity.startTime <= followingStartTime {
                followingStartTime = activity.startTime
                //print("activity checker: startTime = \(activity.startTime)")
            }
        }
        
    }
    
    @IBAction func testNotificationTapped(_ sender: Any) {
        //TODO: - For debug only, make sure to delete button from storyboard too
        
        
        // Test connection
        //        var alert: UIAlertController
        //        if (Reachability.isConnectedToNetwork()) {
        //
        //        alert = Utils.makeSimpleAlert(title: "Connected", message: "Yippie!")
        //        }
        //        else {
        //            alert = Utils.makeSimpleAlert(title: "Not Connected", message: "Rats!")
        //        }
        //
        //        present(alert, animated: true, completion: nil)
    }
    
    @objc func panDraggableHandle(_ sender: UIPanGestureRecognizer) {
        
        guard let topHandle = self.topHandle,
            let botHandle = self.botHandle else {return}
        
        let translation = sender.translation(in: self.view)
        
        if let senderView = sender.view {
            var shouldDrag = true
            
            
            // Move handle
            let newY = senderView.center.y + translation.y
            let doubleY = Double(newY)
            if senderView.tag == 2 {
                
                // Top handle
                // Don't get too close to bottom line or next activity

                if doubleY > (Double(botHandle.center.y) - 0.25 * g_hourVerticalPoints) || doubleY < (precedingEndTime + 0.03) * g_hourVerticalPoints + Double(navigationBar.frame.minY) {
                    shouldDrag = false
                }
                else {
                    //TODO - couldnt get the snapping to work
                    //newYRounded = (Double(newY) / g_hourVerticalPoints * 30).rounded(.toNearestOrAwayFromZero) * g_hourVerticalPoints / 30
                    editingActivity.startTime = Utils.convertYToHour(newY)
                    calendarView.makeActivityDrawables()
                    calendarView.setNeedsDisplay()
                }
            }
                
            else if senderView.tag == 3 {
                // Bot handle
                
                // Don't get too close to top line
                if doubleY < (Double(topHandle.center.y) + 0.25 * g_hourVerticalPoints) || doubleY > (followingStartTime - 0.03) * g_hourVerticalPoints + Double(navigationBar.frame.minY) {
                    shouldDrag = false
                }
                else {
                    editingActivity.endTime = Utils.convertYToHour(newY)
                    calendarView.makeActivityDrawables()
                    calendarView.setNeedsDisplay()
                }
                
                //TODO: - check to see if we're within a 2 minutes of an activity, then snap to flush to it
            }
            
            if (shouldDrag) {
                
                senderView.center = CGPoint(x: senderView.center.x, y: CGFloat(newY))
            }
        }
        
        // Reset translation
        sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        
        // Save when the gesture is complete
        if sender.state.rawValue == 3 {
            let activityRef = displayedDateRef.child(editingActivity.databaseID)
            Utils.saveToRef(calendar: calendar, activityRef: activityRef, startTime: Utils.convertYToHour(topHandle.center.y) , endTime: Utils.convertYToHour(botHandle.center.y), eventDescription: editingActivity.activityDescription, moodScore: editingActivity.moodScore, viewController: self)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if achievements.expCard != nil {
            achievements.expCard?.isHidden = true
        }
    }
    
    // MARK: Notifications
    
    func makeNextNotification(incomingDate: Date) {
        
        // Find incoming hour, schedule notification for 5 minutes after the following hour
        let todaysDate = Date()
        let todaysKey = g_dateFormatter.string(from: todaysDate)
        
        let dateComponents = calendar.dateComponents(in: .current, from: incomingDate)
        
        let notificationHour = Double(dateComponents.hour!)
        var shouldSchedule = true
        
        let displayedDateRef = ref.child(user.uid).child(todaysKey)
        displayedDateRef.observeSingleEvent(of: .value, with:{ (snapshot) in
            
            // Now check to see if we even have any events for today
            
            if let activityDictionary = snapshot.value as? [String:Any]  {
                
                let activityIds = Array(activityDictionary.keys)
                for id in activityIds {
                    guard let values = activityDictionary[id] as? [String:Any],
                        let startTime = values["startTime"] as? Double,
                        let endTime = values["endTime"] as? Double else {continue}
                    
                    // Don't schedule if there's a notification in the previous hour
                    if notificationHour >= startTime && notificationHour <= endTime {
                        shouldSchedule = false
                    }
                }
            }
            
            let startTimePreference = self.userDefaults.integer(forKey: "notifications_start")
            let endTimePreference = self.userDefaults.integer(forKey: "notifications_end")
            
            //TODO - protect against overflow in case no notifications should be scheduled, or schedule for the next day somehow
            
            //Check to see if we're during the hours the user wants notifications.
            if notificationHour < Double(startTimePreference) || notificationHour > Double(endTimePreference) {
                shouldSchedule = false
            }
            
            if shouldSchedule == false {
                // An event exists for this hour. Now we'll use recursion to try to schedule a notification for the following hour
                self.makeNextNotification(incomingDate: Date(timeInterval: 3600, since: incomingDate))
            }
            
            // Schedule the notification
            if shouldSchedule == true {
                let nextHourPlusFiveMin = self.calendar.date(from: DateComponents(calendar: .current, timeZone: dateComponents.timeZone, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!, hour: dateComponents.hour! + 1, minute: 5))
                self.scheduleNotification(date: nextHourPlusFiveMin!)
            }
        })
    }
}

//MARK: - Notifications
extension CalendarViewController: UNUserNotificationCenterDelegate {
    
    func scheduleNotification(date: Date) {
        
        UNUserNotificationCenter.current().delegate = self
        
        // Date Setting
        let fullComponents = calendar.dateComponents(in: .current, from: date)
        
        // Needed to make new components because including the year seems to bug notifications
        let simpleComponents = DateComponents(calendar: calendar, timeZone: .current, month: fullComponents.month, day: fullComponents.day, hour: fullComponents.hour, minute: fullComponents.minute, second: fullComponents.second)
        
        // Making notification content
        let content = UNMutableNotificationContent()
        
        let hour = simpleComponents.hour!
        
        // Encode what hour is being logged (the previous hour to the time of the notification)
        content.userInfo = ["hour":Double(hour - 1)]
        
        // Hour refers to the hour when the notification is schedule. The activity to be logged will be for the previous hour
        switch hour {
        case 0:
            content.title = "Log activity for 11:00PM - 12:00AM"
            // This prevents -1 from being saved as the hour
            content.userInfo = ["hour":Double(23)]
        case 1:
            content.title = "Log activity for 12:00AM - 1:00AM"
            break
        case let x where x < 12:
            content.title = "Log activity for \(hour - 1):00AM - \(hour):00AM"
            break
        case 12:
            content.title = "Log activity for 11:00AM - 12:00PM"
        case 13:
            content.title = "Log activity for 12:00PM - 1:00PM"
        default:
            content.title = "Log activity for \(hour-13):00PM - \(hour - 12):00 PM"
        }
        
        // Add random motivational quote to body
        let rand = Int(arc4random_uniform(UInt32(Quotes.all.count)))
        content.body = Quotes.all[rand]
        
        content.sound = UNNotificationSound.default()
        
        content.categoryIdentifier = "moodCalendarNotification"
        
        // Trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: simpleComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        // Delete any pre-exisiting notification requests
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.add(request) {(error) in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    // Handle notification responses
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        // Check to see which action the user selected
        switch response.actionIdentifier {
            
        // Button clicked
        case "snoozeAction":
            let newDate = Date(timeInterval: 900, since: Date())
            scheduleNotification(date: newDate)
            
        case "quickLogAction":
            let userTextResponse = response as! UNTextInputNotificationResponse
            let userText = userTextResponse.userText
            handleQuickLogResponse(userText: userText, response: response)
            
        case "settingsAction":
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            //performSegue(withIdentifier: "toSettingsView", sender: self)
            
        default:
            //Go to log page with hour filled out
            sendStartTime = response.notification.request.content.userInfo["hour"] as! Double
            
            // If a view has been presented (such as another Logger View), dismiss first
            if let viewController = self.presentedViewController {
                viewController.dismiss(animated: false, completion: {
                    self.performSegue(withIdentifier: "toLogger", sender: self)
                })
            }
            else {
                performSegue(withIdentifier: "toLogger", sender: self)
            }
        }
        
        makeNextNotification(incomingDate: Date())
        completionHandler()
    }
    
    // Configure when notifications arrive
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Shows notification even while app is in foreground.
        completionHandler(.alert)
    }
    
    func handleQuickLogResponse(userText: String, response: UNNotificationResponse) {
        
        // Break down the response so we can extract the score
        let textArray = userText.components(separatedBy: " ")
        if var moodScore: Int = Int(textArray[textArray.count - 1]) {
            
            // Handle cheeky users trying to crash the app
            if moodScore > 10 {
                moodScore = 10
            }
            else if moodScore < 1 {
                moodScore = 1
            }
            var eventDescription = ""
            
            // the -2 is to ignore the mood score and preceding space
            for index in 0...textArray.count-2 {
                eventDescription += textArray[index] + " "
            }
            
            let startTime = response.notification.request.content.userInfo["hour"] as! Double
            
            let dateKey = g_dateFormatter.string(from: Date())
            
            Utils.saveNewActivity(startTime: startTime, endTime: startTime + 1, eventDescription: eventDescription, moodScore: moodScore, dateKey: dateKey, viewController: self)
            
            loadEvents()
        }
            
        else {
            present(Utils.makeSimpleAlert(title: "Invalid QuickLog", message: "Your event could not be saved. Please make sure to type the event description, then a space, then the mood score"), animated: true, completion: nil)
        }
    }
}


