//
//  VideoMessage.swift
//  Dardesh
//
//  Created by Haytham on 25/10/2023.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "photo_placeholder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
