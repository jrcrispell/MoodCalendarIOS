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
    
    @IBOutlet weak var hamburger: UIButton!
    @IBOutlet weak var chartsButton: UIButton!
    
    var oldSnapshotView: UIImageView!
    var snapshotView: UIImageView!
    var menuView: MenuView!
    
    var data: [Double] = [5, 3, 7, 9, 1, 5, 10]
    var dataKeys: [String] = []
    
    var achievements: Achievements!
    
    @IBOutlet weak var daysHighlighter: UIView!
    @IBOutlet weak var screensHighlighter: UIView!
    @IBOutlet weak var hoursHighlighter: UIView!
    @IBOutlet weak var weekFilterHighlighter: UIView!
    @IBOutlet weak var monthFilterHighlighter: UIView!
    @IBOutlet weak var allFilterHighlighter: UIView!
    @IBAction func hamburgerTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if (!Reachability.isConnectedToNetwork()) {
            present(Utils.makeSimpleAlert(title: "Not connected", message: "No internet connection, could load charts data."), animated: true, completion: nil)
            return
        }
        
        hamburger.setImage(Utils.defaultMenuImage(), for: UIControlState.normal)
        
        
        setupLineChart()
        
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
            break;
        case 1:
            print("Month")
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = false
            allFilterHighlighter.isHidden = true
            break;
        case 2:
            print("All")
            weekFilterHighlighter.isHidden = true
            monthFilterHighlighter.isHidden = true
            allFilterHighlighter.isHidden = false
            break;
        default:
            print("Invalid filter button tab tapped")
            break;
        }
    }
    
    
    
    @IBAction func bottomTabTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("Hours")
            hoursHighlighter.isHidden = false
            daysHighlighter.isHidden = true
            screensHighlighter.isHidden = true
            break;
        case 1:
            print("Days")
            hoursHighlighter.isHidden = true
            daysHighlighter.isHidden = false
            screensHighlighter.isHidden = true
            break;
        case 2:
            print("Screens")
            hoursHighlighter.isHidden = true
            daysHighlighter.isHidden = true
            screensHighlighter.isHidden = false
            break;
        default:
            print("Invalid button tab tapped")
            break;
        }
    }
    
    func setupLineChart() {
        
        data = []
        dataKeys = []
        
        var dates: [Date] = []
        var dateStrings: [String] = []
        
        // Sort the data first
        // Get dictionary from achievements
        let scoresDict = achievements.avgMoodScores
        
        // Convert each key to a date
        for day in scoresDict {
            dates.append(g_dateFormatter.date(from: day.key)!)
        }

        // Now we can sort the keys
        dates = dates.sorted()

        // Now use this to sort the data
        for date in dates {
            let value = scoresDict[g_dateFormatter.string(from: date)]
            data.append(value!)
        }
        
        // Now both data and the keys are sorted correctly.

        // Now re-format the keys to a smaller string
        let chartDateFormatter = DateFormatter()
        chartDateFormatter.dateFormat = "M/d"
        for date in dates {
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
        
        line1.colors = [NSUIColor.white]
        line1.valueTextColor = UIColor.clear
        

        
        
        let dataSet = LineChartData()
        dataSet.addDataSet(line1)
        
        line1.circleRadius = 0.0
        
        
        
        lineChartView.data = dataSet
        lineChartView.xAxis.gridColor = Styles.white80Percent
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.point
        lineChartView.legend.textColor = UIColor.white
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor.white
        lineChartView.rightAxis.labelTextColor = UIColor.white
        lineChartView.rightAxis.axisMaximum = 10
        lineChartView.rightAxis.gridColor = Styles.white80Percent
        lineChartView.leftAxis.gridColor = Styles.white80Percent
        lineChartView.leftAxis.labelTextColor = UIColor.white
        lineChartView.leftAxis.axisMaximum = 10
        lineChartView.xAxis.axisLineColor = Styles.white80Percent
        lineChartView.xAxis.labelTextColor = UIColor.white
        lineChartView.borderColor = Styles.white80Percent
        lineChartView.gridBackgroundColor = UIColor.clear
        
        lineChartView.chartDescription?.text = ""
        lineChartView.noDataText = "No data available"
        //lineChartView.drawBordersEnabled = false
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
