//
//  MessageFirestoreListener.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MessageFirestoreListener {
    static let shared = MessageFirestoreListener()
    
    var newMessageListener: ListenerRegistration!
    var updatedMessageListener: ListenerRegistration!
    
    //MARK: - Saving new message
    
    func saveMessage(message: LocalMessage, memberId: String) {
        
        do {
            try firestoreReference(.Message).document(memberId).collection(message.chatRoom).document(message.id).setData(from: message)
            
        } catch {
            print("error saving message to firestore \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - Check for old message
    
    func checkForOldMessage(documentId: String, collectionId: String) {
        firestoreReference(.Message).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            let oldMessage = documents.compactMap { querySnapshot -> LocalMessage? in
                try? querySnapshot.data(as: LocalMessage.self)
            }
            
            oldMessage.sorted(by: {$0.date < $1.date})
            for message in oldMessage {
                RealmManager.shared.save(message)
            }
        }
    }
    
    //MARK: - Listen to new messages
    
    func listenToNewMessages(documentId: String, collectionId: String, lastMessageDate: Date) {
        newMessageListener = firestoreReference(.Message).document(documentId).collection(collectionId).whereField("date", isGreaterThan: lastMessageDate).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case.success(let messageObject):
                        
                        if let message = messageObject {
                            if message.senderId != User.currentId {
                                RealmManager.shared.save(message)
                            }
                        }
                        
                    case.failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
    }
    
    //MARK: - Update message status
    
    func updateMessageStatus(_ message: LocalMessage, userId: String) {
        let values = ["status": "read", "readDate": Date()] as [String: Any]
        
        firestoreReference(.Message).document(userId).collection(message.chatRoom).document(message.id).updateData(values)
    }
    
    //MARK: - Listen for read status update
    
    func listenForReadStatus(documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        updatedMessageListener = firestoreReference(.Message).document(documentId).collection(collectionId).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                if change.type == .modified {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        }
                    case .failure(let error):
                        print("Error decoding", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    ///Stop listeners is important for not using device resource for nothing
    func removeNewMessageListener() {
        newMessageListener.remove()
        updatedMessageListener.remove()
    }
    
}
