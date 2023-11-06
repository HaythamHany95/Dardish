//
//  MessageKitMessage.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//  MK = MessageKit

import Foundation
import MessageKit
import UIKit

class MKMessage: NSObject, MessageType {
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    var status: String
    var readDate: Date
    var incoming: Bool
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        
        case Constants.textType:
            self.kind = MessageKind.text(message.message)
      
        case Constants.photoType:
            let photo = PhotoMessage(path: message.imageUrl)
            self.kind = MessageKind.photo(photo)
            self.photoItem = photo
       
        case Constants.videoType:
            let video = VideoMessage(url: nil)
            self.kind = MessageKind.video(video)
            self.videoItem = video
            
        default:
            print("unknown error")
        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
    
}
