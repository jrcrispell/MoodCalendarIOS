//
//  ViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 9/27/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications
import FirebaseAuth

let g_dateFormatter = DateFormatter()


class CalendarViewController: UIViewController, ViewControllerDelegate, UIPickerViewDelegate
 {
    
    // Date data
    var displayedDate = Date()
    var dateString = ""
    
    // Draggable handles
    var topHandle: UIImageView?
    var botHandle: UIImageView?
    
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    var bounds:CGRect!
    
    @IBOutlet weak var scrollViewTopSpace: NSLayoutConstraint!
    var datePickerVisibile = false
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var background: UIImageView!
    
    
    // Header
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var datePickerTop: NSLayoutConstraint!
    
    @IBOutlet weak var hamburger: UIButton!
    
    let calendar = Calendar.current
    
    // Firebase
    let ref = Database.database().reference()
    var displayedDateRef: DatabaseReference!
    var user: User!
    
    var daysActivities = [CalendarActivity]()
    var editingActivity: CalendarActivity!
    var sendStartTime: Double = 0
    var editMode = false
    
    let userDefaults = UserDefaults.standard
    
    var menuView: MenuView!
    var menuOutsideButton: UIButton!
    var snapshotView: UIImageView!
    var backgroundView: UIImageView!
    
    var smallSnapshotWidth: CGFloat!
    var smallSnapshotHeight: CGFloat!
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        displayedDate = sender.date
        updateDate()
        loadEvents()
        
    }
    
    //TODO: - For debug only, make sure to delete button from storyboard too
    @IBAction func testNotificationTapped(_ sender: Any) {
        
        
        
//        //Schedule notification for 5 seconds from now
//        let fiveSecondsFromNow = Date().addingTimeInterval(5)
//        scheduleNotification(date: fiveSecondsFromNow)
        
        //makeMenu()
        
        //self.calendarView.isHidden = true
        //background.image = nil
        //background.isHidden = true
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.window?.isOpaque = false
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
    
    func makeMenu() {
        let allViewsInXib = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
   
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backgroundView = UIImageView(frame: view.frame)
        backgroundView.image = #imageLiteral(resourceName: "Deep Background 2")
        self.view.addSubview(backgroundView)
        
        snapshotView = UIImageView(frame: view.frame)
        snapshotView.image = image
        
        snapshotView.backgroundColor = UIColor.white
        self.view.addSubview(snapshotView)

        
        // Make menu
        menuView = allViewsInXib?.first as! MenuView
        menuView.logOutButton.addTarget(self, action: #selector(handleLogOut(_: )), for: .touchUpInside)

        menuView.homeButton.addTarget(self, action: #selector(handleHome(_:)), for: .touchUpInside)
        
        menuView.settingsButton.addTarget(self, action: #selector(handleSettings(_:)), for: .touchUpInside)
        self.view.addSubview(menuView)

        menuView.frame = CGRect(x: -bounds.width, y: view.bounds.height / 2 - smallSnapshotHeight/2, width: bounds.width * 0.6, height: bounds.height)

        UIView.animate(withDuration: 0.3, animations: {
            self.snapshotView.frame = (CGRect(x: self.view.bounds.width - self.smallSnapshotWidth / 2, y: self.view.bounds.height / 2 - self.smallSnapshotHeight / 2, width: self.smallSnapshotWidth, height: self.smallSnapshotHeight))
            self.menuView.frame = CGRect(x: 0, y:  self.view.bounds.height / 2 - self.smallSnapshotHeight/2, width: self.bounds.width * 0.6, height: self.bounds.height)
        })

        // Clickable outside area
        menuOutsideButton = UIButton(frame: CGRect(x:  self.menuView.frame.width, y: 0, width: bounds.width, height: bounds.height))
        menuOutsideButton.backgroundColor = nil
        self.view.addSubview(menuOutsideButton)




        menuOutsideButton.addTarget(self, action: #selector(handleMenuOutsideButtonSend(_: ) ), for: .touchUpInside)
        
    }
    
    func animateConstraints() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func showDatePicker() {
        datePickerTop.constant = 8
        scrollViewTopSpace.constant = 8
        datePickerVisibile = true
        animateConstraints()
    }
    
    func hideDatePicker() {
        datePickerTop.constant = -308
        scrollViewTopSpace.constant = 150
        datePickerVisibile = false
        animateConstraints()
    }
    
    @IBAction func dateTapped(_ sender: Any) {
        
        if !datePickerVisibile {
            showDatePicker()
        }
        else {
            hideDatePicker()
        }
    }
    
    @objc func handleLogOut(_ sender: UIButton){
        closeMenu()
        logOutTapped(sender)
    }
    
    @objc func handleSettings(_ sender: UIButton){
        closeMenu()
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @objc func handleHome(_ sender: UIButton){
        closeMenu()
    }
    
    @objc func handleMenuOutsideButtonSend(_ sender: UIButton){
        
        print(sender.description)
        closeMenu()
    }
    
    func closeMenu() {
        //TODO add animation
        
        
        //TODO - fix bug
        UIView.animate(withDuration: 0.3, animations: {
            self.menuOutsideButton.alpha = 0.1
            self.menuView.frame = CGRect(x: -self.bounds.width, y: self.view.bounds.height / 2 - self.smallSnapshotHeight/2, width: self.bounds.width * 100, height: self.bounds.height)
            self.backgroundView.frame = CGRect(x: -self.bounds.width, y: 0, width: self.bounds.width * 4, height: self.bounds.height)
            self.snapshotView.frame = self.view.frame
        }) { (finished) in
            
            

                self.snapshotView.removeFromSuperview()


            self.backgroundView.removeFromSuperview()
            
            self.menuOutsideButton.removeFromSuperview()
            
            self.menuView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = displayedDate
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        self.view.backgroundColor = UIColor.white

        
        smallSnapshotWidth = view.bounds.width * 0.4
        smallSnapshotHeight = view.bounds.height * 0.4
        
        // Set date
        g_dateFormatter.dateFormat = "MMM d, yyyy"
        updateDate()
        
        bounds = self.view.bounds
        
        
        // Authorized Firebase user
        user = Auth.auth().currentUser
        
        // Set delegate
        calendarView.viewControllerDelegate = self
        
        // Set up user preferences
        
        let defaults: [String : Any] = ["notifications_start" : 8, "notifications_end" : 22]
        UserDefaults.standard.register(defaults: defaults)
        
        hamburger.setImage(Utils.defaultMenuImage(), for: UIControlState.normal)
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
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editingActivity = nil
        loadEvents()
        makeNextNotification(incomingDate: Date())
    }
    
    func loadEvents() {
        
        displayedDateRef = ref.child(user.uid).child(dateString)
        displayedDateRef.observeSingleEvent(of: .value, with:{ (snapshot) in
            self.daysActivities = []
            
            guard let activityDictionary = snapshot.value as? [String:Any] else {
                print("No existing activities")
                self.calendarView.makeActivityDrawables()
                self.calendarView.setNeedsDisplay()
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
            
        })
        return
    }
    
    //MARK: - IBActions
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        
        
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
        
        print("Tap")
        print(sender.description)
        let point = sender.location(in: calendarView)
        print(point.x.description + " , " + point.y.description)
        if let activity = calendarView.getSelectedActivity(location: point) {
            editingActivity = activity
        }
        
        // Calculate start hour where user clicked, will be sent in prepare function
        sendStartTime = Double(Int(Utils.convertYToHour(point.y)))
        performSegue(withIdentifier: "toLogger", sender: sender)
        
    }
    
    @IBAction func calendarViewLongPress(_ sender: UILongPressGestureRecognizer) {
        
        // Only act on the "release" touch
        if sender.state.rawValue != 3 {return}
        
        let timeTapped = Utils.convertYToHour(sender.location(in: calendarView).y)
        
        var activityTouched = false
        
        for activity in daysActivities {
            if timeTapped >= activity.startTime && timeTapped <= activity.endTime {
                editActivity(activity: activity)
                activityTouched = true
                editingActivity = activity
            }
            if (!activityTouched) {
                endEditMode()
            }
        }
        
        
    }
    
    func updateDate() {
        datePicker.date = displayedDate
        dateString = g_dateFormatter.string(from: displayedDate)
        dateButton.setTitle(dateString, for: .normal)
    }
    
    func getDaysActivities() -> [CalendarActivity] {
        return daysActivities
    }
    
    @objc func panDraggableHandle(_ sender: UIPanGestureRecognizer) {
        
        guard let topHandle = self.topHandle,
            let botHandle = self.botHandle else {return}
        
        let translation = sender.translation(in: self.view)
        
        
        if let senderView = sender.view {
            var shouldDrag = true
            
            // Move handle
            let newY = senderView.center.y + translation.y
            
            
            if senderView.tag == 2 {
                // Top handle
                
                // Don't get too close to bottom line
                if Double(newY) > (Double(botHandle.center.y) - 0.15 * g_hourVerticalPoints) {
                    shouldDrag = false
                }
                else {
                    editingActivity.startTime = Utils.convertYToHour(newY)
                    calendarView.makeActivityDrawables()
                    calendarView.setNeedsDisplay()
                }
            }
                
            else if senderView.tag == 3 {
                // Bot handle
                
                // Don't get too close to top line
                if Double(newY) < (Double(topHandle.center.y) + 0.15 * g_hourVerticalPoints) {
                    shouldDrag = false
                }
                else {
                    editingActivity.endTime = Utils.convertYToHour(newY)
                    calendarView.makeActivityDrawables()
                    calendarView.setNeedsDisplay()
                }
            }
            
            if (shouldDrag) {
                senderView.center = CGPoint(x: senderView.center.x, y: newY)
            }
        }
        
        // Reset translation
        sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        
        // Save when the gesture is complete
        if sender.state.rawValue == 3 {
            let activityRef = displayedDateRef.child(editingActivity.databaseID)
            Utils.saveToRef(calendar: calendar, activityRef: activityRef, startTime: Utils.convertYToHour(topHandle.center.y) , endTime: Utils.convertYToHour(botHandle.center.y), eventDescription: editingActivity.activityDescription, moodScore: editingActivity.moodScore)
        }
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
        // Remove draggable lines
        for view in calendarView.subviews {
            if view.tag == 2 || view.tag == 3 {
                view.removeFromSuperview()
            }
        }
    }
    
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
        content.title = "Mood Calendar Reminder"
        
        let hour = simpleComponents.hour!
        
        // Encode what hour is being logged (the previous hour to the time of the notification)
        content.userInfo = ["hour":Double(hour - 1)]
        
        // Hour refers to the hour when the notification is schedule. The activity to be logged will be for the previous hour
        switch hour {
        case 0:
            content.body = "Log activity for 11:00PM - 12:00AM"
            // This prevents -1 from being saved as the hour
            content.userInfo = ["hour":Double(23)]
        case 1:
            content.body = "Log activity for 12:00AM - 1:00AM"
            break
        case let x where x < 12:
            content.body = "Log activity for \(hour - 1):00AM - \(hour):00AM"
            break
        case 12:
            content.body = "Log activity for 11:00AM - 12:00PM"
        case 13:
            content.body = "Log activity for 12:00PM - 1:00PM"
        default:
            content.body = "Log activity for \(hour-13):00PM - \(hour - 12):00 PM"
        }
        
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
            // If a view has been presented (such as a Logger View), dismiss
            if let test = self.presentedViewController {
                test.dismiss(animated: false, completion: nil)
            }
            performSegue(withIdentifier: "toSettingsView", sender: self)
            
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
            
            Utils.saveNewActivity(startTime: startTime, endTime: startTime + 1, eventDescription: eventDescription, moodScore: moodScore, dateKey: dateKey)
            
            loadEvents()
        }
            
        else {
            present(Utils.makeSimpleAlert(title: "Invalid QuickLog", message: "Your event could not be saved. Please make sure to type the event description, then a space, then the mood score"), animated: true, completion: nil)
        }
    }
}


