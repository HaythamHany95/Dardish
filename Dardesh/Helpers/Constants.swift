//
//  Constants.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
struct Constants {
    static let currentUser = "Current User"
    static let mainVC = "MainVC"
    static let appVersion = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    static let parantDirectoryStorageReference = "gs://dardesh-hh95.appspot.com"
   //Messages Type
    static let textType = "text"
    static let photoType = "photo"
    static let videoType = "video"
    static let audioType = "audio"
    static let locationType = "location"
    
}
