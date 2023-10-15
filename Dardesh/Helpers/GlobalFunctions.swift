//
//  GlobalFunctions.swift
//  Dardesh
//
//  Created by Haytham on 11/10/2023.
//

import Foundation

func fileNameFrom(fileUrl: String) -> String {
    let name = fileUrl.components(separatedBy: "_").last
    let exactName = name?.components(separatedBy: ".").first
    return exactName!
}

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    
    if seconds < 60 {
        elapsed = "Just now"
        
    } else if seconds < 60 * 60 {
        let mins = Int(seconds/60)
        let minText = mins > 1 ? "mins" : "min"
        elapsed = "\(mins) \(minText)"
        
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds/(60 * 60))
        let hoursText = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) \(hoursText)"

    } else {
        elapsed = "\(date.longDate())"
    }
    
    return elapsed
}

