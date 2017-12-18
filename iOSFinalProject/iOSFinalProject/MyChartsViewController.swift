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
    
    @IBOutlet weak var graphsChartView: LineChartView!
    
    @IBOutlet weak var hamburger: UIButton!
    @IBOutlet weak var chartsButton: UIButton!
    
    var oldSnapshotView: UIImageView!
    var snapshotView: UIImageView!
    var menuView: MenuView!
    
    let data: [Double] = [5, 3, 7, 9, 8, 5, 10]
    
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
        
        
        let formatter = LineChartFormatter()
        let xAxis = XAxis()
        
        var lineChartEntry  = [ChartDataEntry]()
        
        for i in 0..<data.count {
            
            let point = ChartDataEntry(x: Double(i), y: data[i])
            lineChartEntry.append(point)
        }
        xAxis.valueFormatter = formatter
        graphsChartView.xAxis.valueFormatter = xAxis.valueFormatter
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Mood Score")
        
        line1.colors = [NSUIColor.white]
        
        let dataSet = LineChartData()
        dataSet.addDataSet(line1)
        
        graphsChartView.data = dataSet
        
        graphsChartView.chartDescription?.text = "Chart description"
        
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
    
    @objc func handleHome(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.transition(from: oldSnapshotView, to: snapshotView, duration: 0.3, options: .transitionFlipFromLeft) { (finished) in
            self.menuView.closeAfterFlip()
        }
        
        
    }
    
    
    
}
