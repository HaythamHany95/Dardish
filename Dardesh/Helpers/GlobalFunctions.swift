//
//  GlobalFunctions.swift
//  Dardesh
//
//  Created by Haytham on 11/10/2023.
//

import Foundation
import UIKit
import AVFoundation

func fileNameFrom(fileUrl: String) -> String {
    let name = fileUrl.components(separatedBy: "_").last
    let exactName = name?.components(separatedBy: ".").first
    return exactName!
}

///Formatter for the last message appered in ChatTable
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

///To Convert Video Message to an Image
func videoThumbnail(videoURL: URL) -> UIImage {
    do {
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)

        return UIImage(cgImage: cgImage)
    } catch {
        print(error.localizedDescription)

        return UIImage(named: "photo_placeholder")!
    }
}
