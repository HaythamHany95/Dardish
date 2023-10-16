//
//  LocalMessage.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable {
    
   @objc dynamic var id = ""
   @objc dynamic var chatRoom = ""
   @objc dynamic var date = Date()
   @objc dynamic var senderName = ""
   @objc dynamic var senderId = ""
   @objc dynamic var senderInitials = ""
   @objc dynamic var readDate = Date()
   @objc dynamic var type = ""
   @objc dynamic var message = ""
   @objc dynamic var status = ""
   @objc dynamic var audioDuration = 0.0
   @objc dynamic var audioUrl = ""
   @objc dynamic var videoUrl = ""
   @objc dynamic var imageUrl = ""
   @objc dynamic var latitude = 0.0
   @objc dynamic var longitude = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
