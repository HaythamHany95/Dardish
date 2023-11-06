//
//  MessageCellDelegate.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension MessagesVC: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.photoItem != nil && mkMessage.photoItem?.image != nil {
                ///Open the image
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
             
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                
                present(browser, animated: true)
                
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem?.url != nil {
                ///Play the video
                let playerController = AVPlayerViewController()
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                
                playerController.player = player
                
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
    
                present(playerController, animated: true) {
                    playerController.player!.play()
                }
                
            }
        }
        
    }
}
