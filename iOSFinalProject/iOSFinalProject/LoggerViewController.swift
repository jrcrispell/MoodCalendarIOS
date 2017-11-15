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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UINavigationItem!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var moodPicker: UIPickerView!

    
    
    // Incoming data
    var editingActivity: CalendarActivity!
    var displayedDate = Date()
    var incomingStartTime: Double = 8
    var incomingEndTime: Double = 9
    
    // Database
    var ref: DatabaseReference!
    var displayedDateRef: DatabaseReference!
    var activityRef: DatabaseReference!

    
    // Misc
    let calendar = Calendar.current
    let moodPickerData = ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
    var user: User!
    let white80Percent = UIColor.white.withAlphaComponent(0.80)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Database references
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        displayedDateRef = ref.child(user.uid).child(g_dateFormatter.string(from: displayedDate))
        
        // Making new Activity
        if editingActivity == nil {
            deleteButton.isEnabled = false
            moodPicker.selectRow(5, inComponent: 0, animated: true)
            activityRef = displayedDateRef.childByAutoId()

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
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationBar.isTranslucent = true
        navigationBar.isOpaque = true
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        dateLabel.title = g_dateFormatter.string(from: displayedDate)
        
        
    }
    
    func doubleToDate(time: Double) -> Date {
        let hourFractional = time - Double(Int(time))
        let dateComponents = DateComponents(calendar: calendar, hour: Int(time), minute: Int(60*hourFractional))
        return calendar.date(from: dateComponents)!

    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender:UIBarButtonItem) {
        let startTime = startTimePicker.date
        let endTime = endTimePicker.date
        let moodScore = 10 - moodPicker.selectedRow(inComponent: 0)
        
        // Make sure start time is before end time.
        if startTime > endTime{
            self.present(AlertUtils.makeSimpleAlert(title: "Alert", message: "Start date can not be after end date"), animated: true, completion: nil)
            return
        }
        
        // Save values to database
        activityRef.child("startTime").setValue(dateToTime(date: startTime))
        activityRef.child("endTime").setValue(dateToTime(date: endTime))
        activityRef.child("activityDescription").setValue(descriptionField.text)
        activityRef.child("moodScore").setValue(Double(moodScore))
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func dateToTime(date: Date) -> Double {
                
        let hour = Double(calendar.component(.hour, from: date))
        let fractional = Double(calendar.component(.minute, from: date))/60.0
        return hour + fractional
        
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem) {
        activityRef.removeValue()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Slider setup
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return moodPickerData[row]
    }
    
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
