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
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderName, displayName: message.senderName)
       
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
    
}
