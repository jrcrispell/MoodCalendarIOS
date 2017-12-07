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
    
    
    let data: [Double] = [5, 3, 7, 9, 8, 5, 10]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
