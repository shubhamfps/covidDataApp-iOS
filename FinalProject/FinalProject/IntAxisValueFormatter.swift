//
//  IntAxisValueFormatter.swift
//  Lab9
//
//  Created by user186049 on 4/25/21.
//

import Foundation
import Charts

public class IntAxisValueFormatter: NSObject, AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return "\(Int(value)) Million"
    }
}
