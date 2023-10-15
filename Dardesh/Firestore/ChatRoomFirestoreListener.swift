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
    
    //MARK: - Save ChatRoom in Firestore
    func saveChatRoom(_ chatRoom: ChatRoom) {
        do {
            try firestoreReference(.Chat).document(chatRoom.id).setData(from: chatRoom)
            
        } catch {
            print("not able to save documents \(error.localizedDescription)")
        }
    }
    
    //MARK: - Download ChatRoom from Firestore
    func downloadChatRooms(completion: @escaping (_ allChatRooms: [ChatRoom]) -> Void) {
        firestoreReference(.Chat).whereField("senderId", isEqualTo: User.currentId).addSnapshotListener { snapshot, error in
            
            var chatRooms: [ChatRoom] = []
            guard let documets = snapshot?.documents else {
                print("no documents found")
                return
            }
            let allFbChatRooms = documets.compactMap { snapshot -> ChatRoom? in
                return try? snapshot.data(as: ChatRoom.self)
            }
            //avoiding downloading an empty message
            for chatRoom in allFbChatRooms {
                if chatRoom.lastMessage != "" {
                    chatRooms.append(chatRoom)
                }
            }
            //sorting messages by date, new ones comes first
            chatRooms.sorted(by: { $0.date! > $1.date!})
            
            completion(chatRooms)
        }
    }
    
    //MARK: - Delete ChatRoom from Firestore
    func deleteChatRoom(chatRoom: ChatRoom) {
        firestoreReference(.Chat).document(chatRoom.id).delete { error in
            guard error == nil else {
                print("Error removing document\(error?.localizedDescription)")
                return
            }
            print("Document removed successfully")
        }
    }
    
}

