//
//  StartChat.swift
//  Dardesh
//
//  Created by Haytham on 14/10/2023.
//

import Foundation
import Firebase

func startChat(sender: User, receiver: User) -> String {
    var chatRoomId = ""
    let value = sender.id.compare(receiver.id).rawValue
    
    chatRoomId = value < 0 ? (sender.id + receiver.id) : (receiver.id + sender.id)
    
    createChatRoom(chatRoomId: chatRoomId, users: [sender, receiver])
    
    return chatRoomId
}

func createChatRoom(chatRoomId: String, users: [User]) {
    //REMINDER: If user already has a Chatroom in Firestore will not be created.
    var usersToCreateChatsFor: [String]
    usersToCreateChatsFor = []
    
    for user in users {
        usersToCreateChatsFor.append(user.id)
    }
        firestoreReference(.Chat).whereField("chatRoomId", isEqualTo: chatRoomId).getDocuments { querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            if !snapshot.isEmpty {
                for chatData in snapshot.documents {
                    let currentChat = chatData.data() as Dictionary
                    if let currentUserId = currentChat["senderId"] {
                        if usersToCreateChatsFor.contains(currentUserId as! String) {
                            usersToCreateChatsFor.remove(at: usersToCreateChatsFor.firstIndex(of: currentUserId as! String)!)
                        }
                    }
                }
            }
           
            for userId in usersToCreateChatsFor {
                let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)

                let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
                
                let chatRoomObject = ChatRoom(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, memberIds: [senderUser.id, receiverUser.id], lastMessage: "", avatarLink: receiverUser.avatarLink, unreadCounter: 0, date: Date())
                
                //Save chat in firestore
                ChatRoomFirestoreListener.shared.saveChatRoom(chatRoomObject)
                
            }
            
        }
    }

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
