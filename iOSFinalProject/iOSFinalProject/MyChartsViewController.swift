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
    
    @IBOutlet weak var graphsChartView: LineChartView!
    
    @IBOutlet weak var hamburger: UIButton!
    
    let data: [Double] = [5, 3, 7, 9, 8, 5, 10]
    
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
        let menuView = xibViews?.first as! MenuView
        menuView.setInitialPosition(superViewBounds: view.bounds)
        let views = menuView.makeViews(superView: view)
        view.addSubview(views.0)
        view.addSubview(views.1)
        view.addSubview(views.2)
        view.addSubview(views.3)
        view.addSubview(menuView)
        menuView.animateIn()
       // menuView.animateFromViewController()

    }


}
