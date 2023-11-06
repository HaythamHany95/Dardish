//
//  ChatRoomDatabase.swift
//  Dardesh
//
//  Created by Haytham on 15/10/2023.
//

import Foundation
import Firebase

class ChatRoomFirestoreListener {
    static let shared = ChatRoomFirestoreListener()
    
    //MARK: - Save ChatRoom
    
    func saveChatRoom(_ chatRoom: ChatRoom) {
        do {
            try firestoreReference(.Chat).document(chatRoom.id).setData(from: chatRoom)
            
        } catch {
            print("not able to save documents \(error.localizedDescription)")
        }
    }
    
    //MARK: - Download ChatRoom
    
    func downloadChatRooms(completion: @escaping (_ allChatRooms: [ChatRoom]) -> Void) {
        firestoreReference(.Chat).whereField("senderId", isEqualTo: User.currentId!).addSnapshotListener { snapshot, error in
            
            var chatRooms: [ChatRoom] = []
            guard let documets = snapshot?.documents else {
                print("no documents found")
                return
            }
            let allFbChatRooms = documets.compactMap { snapshot -> ChatRoom? in
                return try? snapshot.data(as: ChatRoom.self)
            }
            
            //Avoiding downloading an empty message
            for chatRoom in allFbChatRooms {
                if chatRoom.lastMessage != "" {
                    chatRooms.append(chatRoom)
                }
            }
            
            //Sorting messages by date, new ones comes first
            chatRooms.sorted(by: { $0.date! > $1.date!})
            
            completion(chatRooms)
        }
    }
    
    //MARK: - Delete ChatRoom
    
    func deleteChatRoom(chatRoom: ChatRoom) {
        firestoreReference(.Chat).document(chatRoom.id).delete { error in
            guard error == nil else {
                print("Error removing document\(String(describing: error?.localizedDescription))")
                return
            }
            print("Document removed successfully")
        }
    }
    
    //MARK: - Reset unread counter
    
    func clearUnreadCounter(chatRoom: ChatRoom) {
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        saveChatRoom(newChatRoom)
    }
    
    func clearUnreadCounterWith(chatRoomId: String) {
        firestoreReference(.Chat).whereField("chatRoomId", isEqualTo: chatRoomId).whereField("senderId", isEqualTo: User.currentId!).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else { return }
            
            let allChatRooms = documents.compactMap { querySnapshot -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            if allChatRooms.count > 0 {
                self.clearUnreadCounter(chatRoom: allChatRooms.first!)
            }
        }
    }
    
    //MARK: - Update chatRoom with new message
    
    private func updateChatRoomWithNewMessage(chatRoom: ChatRoom, lastMessage: String) {
        var tempChatRoom = chatRoom
        
        if tempChatRoom.senderId != User.currentId {
            tempChatRoom.unreadCounter += 1
        }
        
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        saveChatRoom(chatRoom)
    }
    
    func updateChatRooms(chatRoomId: String, lastMessage: String) {
        firestoreReference(.Chat).whereField("chatRoomId", isEqualTo: chatRoomId).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else { return }
            
            let allChatRooms = documents.compactMap { querySnapshot -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allChatRooms {
                self.updateChatRoomWithNewMessage(chatRoom: chatRoom, lastMessage: lastMessage)
            }
        }
    }
}

