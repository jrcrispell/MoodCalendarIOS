//
//  LineChartFormatter.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/4/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import UIKit
import Charts

@objc(LineChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter {
    
    var dayKeys: [String] = []
    
    init(dayKeys: [String]) {
        super.init()
        self.dayKeys = dayKeys
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        return dayKeys[Int(value)]
    }
}


