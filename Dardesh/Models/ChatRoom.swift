//
//  ChatRoom.swift
//  Dardesh
//
//  Created by Haytham on 13/10/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatRoom: Codable {
    var id: String = ""
    var chatRoomId: String = ""
    var senderId: String = ""
    var senderName: String = ""
    var receiverId: String = ""
    var receiverName: String = ""
    var memberIds: [String] = [""]
    var lastMessage: String = ""
    var avatarLink: String = ""
    var unreadCounter: Int = 0
    @ServerTimestamp var date = Date()
}
