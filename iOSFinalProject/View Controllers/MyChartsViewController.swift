//
//  ChartsViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/4/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit
import Charts

class MyChartsViewController: UIViewController {
    
    var oldSnapshot: UIImage!
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lineChartView2: LineChartView!
    @IBOutlet weak var lineChartView3: LineChartView!
    @IBOutlet weak var hamburger: UIButton!
    @IBOutlet weak var chartsButton: UIButton!
    
    var oldSnapshotView: UIImageView!
    var snapshotView: UIImageView!
    var menuView: MenuView!
    
    var data: [Double] = [5, 3, 7, 9, 1, 5, 10]
    var dataKeys: [String] = []
    
    var selectedFilter: Int = 1
    var selectedDataType: Int = 1
    
    var achievements: Achievements!
    
    let chartDateFormatter = DateFormatter()
    
    
    @IBOutlet weak var daysHighlighter: UIView!
    @IBOutlet weak var screensHighlighter: UIView!
    @IBOutlet weak var hoursHighlighter: UIView!
    @IBOutlet weak var weekFilterHighlighter: UIView!
    @IBOutlet weak var monthFilterHighlighter: UIView!
    @IBOutlet weak var allFilterHighlighter: UIView!
    @IBOutlet weak var filterView: UIView!
    
    
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    
    @IBAction func hamburgerTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartDateFormatter.dateFormat = "M/d"
    
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could load charts data."), animated: true, completion: nil)
            return
        }
        
        hamburger.setImage(Utils.defaultMenuImage(), for: UIControlState.normal)
        setupLineChart(dataType: 1)
        
        // Menu
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
        
        
        menuView.homeButton.addTarget(self, action: #selector(handleHome(_:)), for: .touchUpInside)
    }
    
    @IBAction func filterTabTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("Week")
            weekFilterHighlighter.isHidden = false
            monthFilterHighlighter.isHidden = true
            allFilterHighlighter
                .isHidden = true
            selectedFilter = 0
            break;
        case 1:
            print("Month")
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = false
            allFilterHighlighter.isHidden = true
            selectedFilter = 1
            break;
        case 2:
            print("All")
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = true
            allFilterHighlighter.isHidden = false
            selectedFilter = 2
            break;
        default:
            print("Invalid filter button tab tapped")
            break;
        }
        setupLineChart(dataType: selectedDataType)
    }
    
    
    
    @IBAction func bottomTabTapped(_ sender: UIButton) {
        selectedDataType = sender.tag
        switch sender.tag {
        case 0:
            print("Hours")
            hoursHighlighter.isHidden = false
            daysHighlighter.isHidden = true
            screensHighlighter.isHidden = true
            screensHighlighter.isHidden = true
            weekButton.isHidden = false
            monthButton.isHidden = false
            weekButton.isHidden = true
            monthButton.isHidden = true
            allButton.isHidden = true
            allFilterHighlighter.isHidden = true
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = true
            filterView.isHidden = true
            break;
        case 1:
            print("Days")
            selectedFilter = 1
            hoursHighlighter.isHidden = true
            daysHighlighter.isHidden = false
            screensHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = false
            weekButton.isHidden = false
            monthButton.isHidden = false
            allButton.isHidden = false
            filterView.isHidden = false

            break;
        case 2:
            print("Screens")
            hoursHighlighter.isHidden = true
            daysHighlighter.isHidden = true
            screensHighlighter.isHidden = false
            weekButton.isHidden = true
            monthButton.isHidden = true
            allButton.isHidden = true
            allFilterHighlighter.isHidden = true
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = true
            filterView.isHidden = true

            break;
        default:
            print("Invalid button tab tapped")
            break;
        }
        setupLineChart(dataType: selectedDataType)
    }
    
    func setupLineChart(dataType: Int) {
        
        switch dataType {
        case 0 : // Mood Score by Hour
            moodScoresByHour(filter: selectedFilter)
            break;
        case 1:  // Mood Score By Day
            moodScoresByDay(filter: selectedFilter)
            break;
        case 2:  // Depression Screen scores
            depressionScores()
            break;
        default: // Shouldn't happen.
            break;
        }
    }
    
    func moodScoresByHour(filter: Int) {
        lineChartView.isHidden = true
        lineChartView2.isHidden = true
        lineChartView3.isHidden = false
        
        let scoresDict = achievements.hourScores
        data = []
        dataKeys = []
        var hourStrings: [String] = []
        
        var scoreKeys: [Int] = []
        for score in scoresDict {
            scoreKeys.append(score.key)
        }
        scoreKeys = scoreKeys.sorted()
        
        for key in scoreKeys {
            let scoreArray = scoresDict[key]!
            var scoreSum = 0
            for scoreValue in scoreArray {
                scoreSum += scoreValue
            }
            data.append(Double(scoreSum)/Double(scoreArray.count))
        
            
            var hourString = ""
            if key == 0 {
                hourString = "12am"
            }
            else if key == 12 {
                hourString = "12pm"
            }
            else if key == 11 || key == 10 {
                hourString = key.description + "am"
            }
                
                // Adding a space at the beginning so the hours are right-aligned
            else if key < 10 {
                hourString = "  " + key.description + "am"
            }
            else if key < 22 {
                hourString = "  " + (key - 12).description + "pm"
            }
            else {
                hourString = (key - 12).description + "pm"
            }
            hourStrings.append(hourString)
    }
        
            chartsButton.setTitle("Average Mood Score", for: .normal)
        
        let formatter = LineChartFormatter(dayKeys: hourStrings)
        let xAxis = XAxis()
        
        var lineChartEntry  = [ChartDataEntry]()
        
        for i in 0..<data.count {
            let point = ChartDataEntry(x: Double(i), y: data[i])
            lineChartEntry.append(point)
        }
        xAxis.valueFormatter = formatter
        lineChartView3.xAxis.valueFormatter = xAxis.valueFormatter
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Mood Score")
        
        line1.circleRadius = 0.0
        line1.colors = [NSUIColor.white]
        line1.valueTextColor = UIColor.clear
        
        let dataSet = LineChartData()
        dataSet.addDataSet(line1)
        lineChartView3.data = dataSet
        customizeLineChart(lineChartView: lineChartView3, dataType: selectedDataType)

    }
    
    func depressionScores() {
        
        lineChartView.isHidden = true
        lineChartView2.isHidden = false
        lineChartView3.isHidden = true
        
        let scoresDict = achievements.screenScores
        
        data = []
        dataKeys = []
        var dateStrings: [String] = []
        
        // Convert each key to date, then to a shorter string
        // And add to data array
        for score in scoresDict {
            let date = g_dateFormatter.date(from: score.key)!
            dateStrings.append(chartDateFormatter.string(from: date))
            data.append(Double(score.value))
        }
        lineChartView2.xAxis.axisMaximum = Double(data.count)
        lineChartView2.xAxis.granularity = 1
        
        chartsButton.setTitle("Depression Scores", for: .normal)
        
        
        
        let formatter = LineChartFormatter(dayKeys: dateStrings)
        let xAxis = XAxis()

        var lineChartEntry  = [ChartDataEntry]()

        for i in 0..<data.count {
            let point = ChartDataEntry(x: Double(i), y: data[i])
            lineChartEntry.append(point)
        }
        xAxis.valueFormatter = formatter
        lineChartView2.xAxis.valueFormatter = xAxis.valueFormatter
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Mood Score")
        
        line1.colors = [NSUIColor.white]
        line1.valueTextColor = UIColor.clear
        
        let dataSet = LineChartData()
        dataSet.addDataSet(line1)
        
        
        lineChartView2.data = dataSet

        customizeLineChart(lineChartView: lineChartView2, dataType: selectedDataType)
    }
    
    func moodScoresByDay(filter: Int) {
        lineChartView.isHidden = false
        lineChartView2.isHidden = true
        lineChartView3.isHidden = true

        
        lineChartView.xAxis.granularity = 1

        
        var dates: [Date] = []
        var dateStrings: [String] = []
        
        data = []
        dataKeys = []
        // Sort the data first
        // Get dictionary from achievements
        let scoresDict = achievements.avgMoodScores
        
        // Convert each key to a date
        for day in scoresDict {
            dates.append(g_dateFormatter.date(from: day.key)!)
        }
        
        // Now we can sort the keys
        dates = dates.sorted()
        
        var filteredDates: [Date] = []
        
        // Now apply the filter
        switch filter {
        case 0: // Week
            for date in dates {
                if date >= Date(timeIntervalSinceNow: -7*Utils.secondsInADay) {
                    filteredDates.append(date)
                }
            }
            break;
        case 1: // Month
            for date in dates {
                if date >= Date(timeIntervalSinceNow: -30*Utils.secondsInADay) {
                    filteredDates.append(date)
                }
            }
            break;
        case 2: // All time
            for date in dates {
                    filteredDates.append(date)
            }
            break;
        default: // Should not happen
            break;
        }
        
        // Now use this to sort the data
        for date in filteredDates {
            let value = scoresDict[g_dateFormatter.string(from: date)]
            data.append(value!)
        }
        
        // Now both data and the keys are sorted correctly.
        
        // Now re-format the keys to a smaller string
        for date in filteredDates {
            dateStrings.append(chartDateFormatter.string(from: date))
        }
        
        
        chartsButton.setTitle("Average Mood Score", for: .normal
        )
        
        let formatter = LineChartFormatter(dayKeys: dateStrings)
        
        let xAxis = XAxis()
        var lineChartEntry  = [ChartDataEntry]()
        
        for i in 0..<data.count {
            let point = ChartDataEntry(x: Double(i), y: data[i])
            lineChartEntry.append(point)
        }
        xAxis.valueFormatter = formatter
        lineChartView.xAxis.valueFormatter = xAxis.valueFormatter
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Mood Score")
        
        line1.circleRadius = 0.0
        line1.colors = [NSUIColor.white]
        line1.valueTextColor = UIColor.clear
        
        let dataSet = LineChartData()
        dataSet.addDataSet(line1)
        
        line1.circleRadius = 0.0
        lineChartView.data = dataSet

        
        customizeLineChart(lineChartView: lineChartView, dataType: selectedDataType)
    }
    
    func customizeLineChart(lineChartView: LineChartView, dataType: Int) {
        
        lineChartView.leftAxis.xOffset = 10

        switch dataType {
        case 0:
            lineChartView.rightAxis.axisMaximum = 10
            lineChartView.leftAxis.axisMaximum = 10
            break;
        case 1:
            lineChartView.rightAxis.axisMaximum = 10
            lineChartView.leftAxis.axisMaximum = 10
            break;
        case 2:
            lineChartView.rightAxis.axisMaximum = 90
            lineChartView.leftAxis.axisMaximum = 90
            lineChartView.leftAxis.xOffset = 9.5
            lineChartView.rightAxis.xOffset = 4.5

            break;
        default:
            break;
        }
        
        lineChartView.xAxis.gridColor = Styles.white80Percent
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.legend.textColor = UIColor.white
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor.white
        lineChartView.rightAxis.labelTextColor = UIColor.clear
        lineChartView.rightAxis.gridColor = Styles.white80Percent
        lineChartView.leftAxis.gridColor = Styles.white80Percent
        lineChartView.leftAxis.labelTextColor = UIColor.white
        lineChartView.xAxis.axisLineColor = Styles.white80Percent
        lineChartView.xAxis.labelTextColor = UIColor.white
        lineChartView.borderColor = Styles.white80Percent
        lineChartView.gridBackgroundColor = UIColor.clear
        lineChartView.dragEnabled = false
        lineChartView.dragXEnabled = false
        lineChartView.dragYEnabled = false
        
        lineChartView.chartDescription?.text = ""
        lineChartView.noDataText = "No data available"
        lineChartView.fitScreen()
    }
    
    @objc func handleHome(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.transition(from: oldSnapshotView, to: snapshotView, duration: 0.3, options: .transitionFlipFromLeft) { (finished) in
            self.menuView.closeAfterFlip()
        }
        
        
    }
    
    
    
}
