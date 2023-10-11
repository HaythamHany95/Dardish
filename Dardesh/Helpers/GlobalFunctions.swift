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

