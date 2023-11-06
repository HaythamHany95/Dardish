//
//  PhotoMessage.swift
//  Dardesh
//
//  Created by Haytham on 25/10/2023.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(filePath: path)
        self.placeholderImage = UIImage(named: "photo_placeholder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
