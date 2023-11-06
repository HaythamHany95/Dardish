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

class Outgoing {
    
    class func sendMessage(chatId: String, memberIds: [String], text: String?, video: Video?, audio: String?, audioDuration: Float = 0.0, image: UIImage?, location: String? ) {
        
        ///1. create local message from the data we have "LocalMessage" model
        let currentUser = User.currentUser!
        let message = LocalMessage()
        
        message.id = UUID().uuidString
        message.chatRoom = chatId
        message.date = Date()
        message.senderName = currentUser.username
        message.senderId = currentUser.id
        message.senderInitials = String(currentUser.username.first!)
        message.status = "✔️"
        
        ///2. Check message type { text, video, audio, image, location ??}
        if text != nil {
            sendText(message: message, text: text!, memberIds: memberIds)
        }
        if image != nil {
            sendImage(message, image: image!, memberIds: memberIds)
        }
        if video != nil {
            sendVideo(message, video: video!, memberIds: memberIds)
        }
        if audio != nil {
            //TODO:  sendAudio()
            
        }
        if location != nil {
            saveMessage(message: message, memberIds: memberIds)
        }
        
        //TODO: Send push notificatio
        
        ///Update chatRoom
        ChatRoomFirestoreListener.shared.updateChatRooms(chatRoomId: chatId, lastMessage: message.message)
        
    }
    
    //MARK: - Save message locally and in firestore
    
    class func saveMessage(message: LocalMessage, memberIds: [String]) {
        ///For saving locally
        RealmManager.shared.save(message)
        ///For saving in firestore
        for memberId in memberIds {
            MessageFirestoreListener.shared.saveMessage(message: message, memberId: memberId)
        }
    }
    
}

//MARK: - Send Message Functions -
///Depends On Message Type

//MARK: - Send message with text

func sendText(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = Constants.textType
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

//MARK: - Send message with image

func sendImage(_ message: LocalMessage, image: UIImage, memberIds: [String]) {
    message.message = "Photo Message"
    message.type = Constants.photoType
    
    ///To make a unique ID for ImageUrl in file directory
    let fileName = Date().stringDate()
    
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoom)" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(image, directory: fileDirectory) { imageUrl in
        
        if imageUrl != nil {
            message.imageUrl = imageUrl!
            
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }
    
}

//MARK: - Send message with video

func sendVideo(_ message: LocalMessage, video: Video, memberIds: [String]) {
    message.message = "Video Message"
    message.type = Constants.videoType
    
    ///To make a unique ID for ImageUrl in file directory
    let fileName = Date().stringDate()
    
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoom)" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoom)" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()

    editor.process(video: video) { processedVideo, videoUrl in
       
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(videoURL: tempPath)
            
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { imageLink in
                
                if imageLink != nil {
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { videoLink in
                        
                        message.videoUrl = videoLink ?? ""
                        message.imageUrl = imageLink ?? ""
                        
                        Outgoing.saveMessage(message: message, memberIds: memberIds)

                        
                    }
                }
            }
                                        
           
        }
    }
}

//MARK: - Send message with location

func sendLocation(_ message: LocalMessage, memberIds: [String]) {
    let currentLocation = LocationManager.shared.currentLocation
    
    message.message = "Location Message"
    message.type = Constants.locationType
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

