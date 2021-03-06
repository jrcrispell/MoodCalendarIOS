//
//  LoggerViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/6/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoggerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!

    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var deleteHighlighter: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var moodPicker: UIPickerView!
    
    @IBOutlet weak var emojiPicker: UIPickerView!
    
    // Incoming data
    var editingActivity: CalendarActivity!
    var displayedDate = Date()
    var incomingStartTime: Double = 8
    var incomingEndTime: Double = 9
    var incomingExactStartTime: Double = 8
    var precedingEndTime: Double = 0
    
    // Database
    var ref: DatabaseReference!
    var displayedDateRef: DatabaseReference!
    var activityRef: DatabaseReference!

    
    // Misc
    let calendar = Calendar.current
    let moodPickerData = ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
    let emojiPickerData = [#imageLiteral(resourceName: "HappyFace"), #imageLiteral(resourceName: "MiddleFace"), #imageLiteral(resourceName: "SangryFace")]
    var user: User!
    let white80Percent = UIColor.white.withAlphaComponent(0.80)
    
    //TODO: use preceding activity to improve date picker logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Hiding emojipicker for now in case I forget to get to it.
        emojiPicker.isHidden = true
        
        
        // Database references
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        displayedDateRef = ref.child(user.uid).child(g_dateFormatter.string(from: displayedDate))
        
        // Making new Activity
        if editingActivity == nil {
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
            deleteHighlighter.isHidden = true
            moodPicker.selectRow(5, inComponent: 0, animated: true)
            activityRef = displayedDateRef.childByAutoId()
            
            // Judge if this activity should by default start at the end of the previous activity
            if incomingExactStartTime - precedingEndTime < 0.60 {
                incomingStartTime = precedingEndTime
            }
            
            // Judge if end-time should be whatever the current time is
            let now = Utils.dateToTime(calendar: calendar, date: Date())
            if abs(now - incomingEndTime) < 0.95 {
                incomingEndTime = now
            }
        }
            
        else {
            // Editing existing Activity
            incomingStartTime = editingActivity.startTime
            incomingEndTime = editingActivity.endTime
            descriptionField.text = editingActivity.activityDescription
            moodPicker.selectRow(10 - editingActivity.moodScore, inComponent: 0, animated: true)
            activityRef = displayedDateRef.child(editingActivity.databaseID)
        }
        
        startTimePicker.setDate(doubleToDate(time: incomingStartTime), animated: true)
        endTimePicker.setDate(doubleToDate(time: incomingEndTime), animated: true)
        startTimePicker.setValue(UIColor.white, forKey: "textColor")
        endTimePicker.setValue(UIColor.white, forKey: "textColor")
        moodPicker.setValue(UIColor.white, forKey: "textColor")

        // Navigation Bar
        dateLabel.text = g_dateFormatter.string(from: displayedDate)
        
        
    }
    
    func doubleToDate(time: Double) -> Date {
        let hourFractional = time - Double(Int(time))
        let dateComponents = DateComponents(calendar: calendar, hour: Int(time), minute: Int(60*hourFractional))
        return calendar.date(from: dateComponents)!
    }
    
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not save activity"), animated: true, completion: nil)
            return
        }
        
        let startDate = startTimePicker.date
        let endDate = endTimePicker.date
        let moodScore = 10 - moodPicker.selectedRow(inComponent: 0)
        
        // Make sure start time is before end time.
        if startDate > endDate{
            self.present(Utils.makeSimpleAlert(title: "Alert", message: "Start date can not be after end date"), animated: true, completion: nil)
            return
        }
        else if Utils.dateToTime(calendar: calendar, date: endDate) - Utils.dateToTime(calendar: calendar, date: startDate) < 0.25 {
            self.present(Utils.makeSimpleAlert(title: "Alert", message: "Activities must be at least 15 minutes long"), animated: true, completion: nil)
            return
        }
        
        // Save values to database
        Utils.saveToRef(calendar: calendar, activityRef: activityRef, startTime: Utils.dateToTime(calendar: calendar, date: startDate), endTime: Utils.dateToTime(calendar: calendar, date: endDate), eventDescription: descriptionField.text!, moodScore: moodScore, viewController: self)
        
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could not delete activity"), animated: true, completion: nil)
            return
        }
        
        let confirmAlert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this activity?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            self.activityRef.removeValue()
            self.dismiss(animated: true, completion: nil)
        }
        confirmAlert.addAction(cancelButton)
        confirmAlert.addAction(deleteButton)
        present(confirmAlert, animated: true, completion: nil)
        
        
        

    }
    
    //MARK: - Slider setup
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // Emoji
        if pickerView.tag == 1 {
            return 3
        }
            // Mood score
        else if pickerView.tag == 2 {
        return 10
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 2 {
        return moodPickerData[row]
        }
        else {return ""}
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        if pickerView.tag == 1 {
//
//        }
//        return nil
//    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView.tag == 1 {
            return 60
        }
        else {return 30}
    }
    
    //TODO: left off here
    
    // Keyboard dismissals
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        descriptionField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionField.resignFirstResponder()
        return true
    }
    
    // Color for mood score picker

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let rowData = moodPickerData[row]
        return NSAttributedString(string: rowData, attributes: Styles.moodPickerAttributes)
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
