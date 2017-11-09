//
//  LoggerViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/6/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

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
    
    // Misc
    let calendar = Calendar.current
    let moodPickerData = ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editingActivity == nil {
            deleteButton.isEnabled = false
            moodPicker.selectRow(5, inComponent: 0, animated: true)
        }
        else {
            incomingStartTime = editingActivity.startTime
            incomingEndTime = editingActivity.endTime
            descriptionField.text = editingActivity.activityDescription
            moodPicker.selectRow(10 - editingActivity.moodScore, inComponent: 0, animated: true)
        }
        
        startTimePicker.setDate(doubleToDate(time: incomingStartTime), animated: true)
        endTimePicker.setDate(doubleToDate(time: incomingEndTime), animated: true)

        // Navigation Bar
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationBar.isTranslucent = true
        navigationBar.isOpaque = true
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"        
        dateLabel.title = dateFormatter.string(from: displayedDate)
        
        
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
        let start = startTimePicker.date.description
        print(start)
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
