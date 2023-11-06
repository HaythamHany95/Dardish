//
//  IncomingMessage.swift
//  Dardesh
//
//  Created by Haytham on 17/10/2023.
//

import Foundation
import MessageKit

class Incoming {
    var messageViewController: MessagesViewController
    
    init(messageViewController: MessagesViewController) {
        self.messageViewController = messageViewController
    }
    
    //MARK: - Convert localMessage to MkMessage
    
    func createMkMessage(localMessage: LocalMessage) -> MKMessage {
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == Constants.photoType {
            
            let photo = PhotoMessage(path: localMessage.imageUrl)
            
            mkMessage.photoItem = photo
            mkMessage.kind = MessageKind.photo(photo)
            
            FileStorage.downloadImage(imageUrl: localMessage.imageUrl) {  image in
                mkMessage.photoItem?.image = image
                
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == Constants.videoType {
            
            FileStorage.downloadImage(imageUrl: localMessage.imageUrl) { thumbnail in
                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { isReadyToPlay, videoFileName in
                    
                    let videoLink = URL(fileURLWithPath: fileInDocumentDirectory(fileName: videoFileName))
                    let video = VideoMessage(url: videoLink)
                    
                    mkMessage.videoItem = video
                    mkMessage.kind = MessageKind.video(video)
                    mkMessage.videoItem?.image = thumbnail
                    
                    self.messageViewController.messagesCollectionView.reloadData()
                    
                    
                }
            }
        }
        
        return mkMessage
    }
}
