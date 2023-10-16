//
//  OutgoingMessage.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

class OutgoingMessage {
    
    class func sendMessage(chatId: String, memberIds: [String], text: String?, video: Video?, audio: String?, audioDuration: Float = 0.0, image: UIImage?, location: String? ) {
        ///1. create local message from the data we have "LocalMessage" model
        let message = LocalMessage()
        let currentUser = User.currentUser!
        
        message.id = UUID().uuidString
        message.chatRoom = chatId
        message.date = Date()
        message.senderName = currentUser.username
        message.senderId = currentUser.id
        message.senderInitials = String(currentUser.username.first!)
        message.status = "Sent"
        
        ///2. check message type { text, video, audio, image, location ??}
        if text != nil {
            sendText(message: message, text: text!, memberIds: memberIds)
        }
        if image != nil {
            //TODO: sendImage()
        }
        if video != nil {
            //TODO: sendVideo()
        }
        if audio != nil {
            //TODO: sendAudio()
            
        }
        if location != nil {
            //TODO: sendLocation()
        }
        
        ///3.Save the message locally and in firestore
        //TODO: Send push notificatio
        //TODO: Update chatRoom
        ///
    }
    
    //MARK: - Save message locally and in firestore
    
    class func saveMessage(message: LocalMessage, memberIds: [String]) {
        //For saving locally
        RealmManager.shared.save(message)
        //For saving in firestore
        for memberId in memberIds {
            MessageFirestoreListener.shared.saveMessage(message: message, memberId: memberId)
        }
    }
    
}

func sendText(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = Constants.textType
    
    OutgoingMessage.saveMessage(message: message, memberIds: memberIds)
}
