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


class CalendarViewController: UIViewController, ViewControllerDelegate {
    
    // Date data
    var displayedDate = Date()
    var dateString = ""

    // Header
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var calendarView: CalendarView!
    
    let calendar = Calendar.current

    let ref = Database.database().reference()

    var daysActivities = [CalendarActivity]()
    
    var editingActivity: CalendarActivity!
    var user: User!
    
    var sendStartTime: Double = 0
    
    //TODO: - For debug only, make sure to delete button from storyboard too
    @IBAction func testNotificationTapped(_ sender: Any) {
        
        // Schedule notification for 5 seconds from now
        let fiveSecondsFromNow = Date().addingTimeInterval(5)
        scheduleNotification(date: fiveSecondsFromNow)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date
        g_dateFormatter.dateFormat = "MMM d, yyyy"
        updateDate()
        
        // Authorized Firebase user
        user = Auth.auth().currentUser
        
        // Set delegate
        calendarView.viewControllerDelegate = self
    }
    
    func loadEvents() {
        
        //TODO: - this is unsecure, set up database rules
        let displayedDateRef = ref.child(user.uid).child(dateString)
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
            self.present(AlertUtils.makeSimpleAlert(title: "Sign out error", message: error.localizedDescription), animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    
    
    func updateDate() {
        dateString = g_dateFormatter.string(from: displayedDate)
        dateButton.setTitle(dateString, for: .normal)
    }
    
    func getDaysActivities() -> [CalendarActivity] {
        return daysActivities
    }
    
    @IBAction func calendarViewTapped(_ sender: UITapGestureRecognizer) {
        print("Tap")
        print(sender.description)
        let point = sender.location(in: calendarView)
        print(point.x.description + " , " + point.y.description)
        if let activity = calendarView.getSelectedActivity(location: point) {
            editingActivity = activity
        }
        
        // Calculate start hour where user clicked, will be sent in prepare function
        sendStartTime = Double(Int(CalendarView.convertYToHour(point.y)))
        performSegue(withIdentifier: "toLogger", sender: sender)

    }

    @IBAction func calendarViewLongPress(_ sender: UILongPressGestureRecognizer) {
        
        // Only act on the "release" touch
        if sender.state.rawValue != 3 {return}
            
        
        print("Long Press - \(sender.state.rawValue.description)")
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
            
            //TODO: - Check to see if we're during the hours the user wants notifications.
            //        if notificationHour < Double(preferencesData.notificationStartTime) || notificationHour > Double(preferencesData.notificationEndTime) {
            //            shouldSchedule = false
            //        }
            
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
            
            // Database references
            user = Auth.auth().currentUser
            let todaysRef = ref.child(user.uid).child(dateKey)
            let activityRef = todaysRef.childByAutoId()

            // Save values to database
            activityRef.child("startTime").setValue(startTime)
            activityRef.child("endTime").setValue(startTime + 1)
            activityRef.child("activityDescription").setValue(eventDescription)
            activityRef.child("moodScore").setValue(Double(moodScore))
            
            loadEvents()
        }
            
        else {
            present(AlertUtils.makeSimpleAlert(title: "Invalid QuickLog", message: "Your event could not be saved. Please make sure to type the event description, then a space, then the mood score"), animated: true, completion: nil)
        }
    }
}


