//
//  GalleryControllerDelegate.swift
//  Dardesh
//
//  Created by Haytham on 24/10/2023.
//

import Foundation
import Gallery

extension MessagesVC: GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        
        if images.count > 0 {
            
            images.first?.resolve { image in
                self.send(text: nil, image: image, video: nil, location: nil, audio: nil)
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        send(text: nil, image: nil, video: video, location: nil, audio: nil)
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
    
    
}
