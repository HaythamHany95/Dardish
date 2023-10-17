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
    
    func saveMessage(message: LocalMessage, memberId: String) {
        
        do {
            try firestoreReference(.Message).document(memberId).collection(message.chatRoom).document(message.id).setData(from: message)
            
        } catch {
            print("error saving message to firestore \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - Check for old messages in Firestore
    
    func checkForOldMessage(documentId: String, collectionId: String) {
        firestoreReference(.Message).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            var oldMessage = documents.compactMap { querySnapshot -> LocalMessage? in
                try? querySnapshot.data(as: LocalMessage.self)
            }
            
            oldMessage.sorted(by: {$0.date < $1.date})
            for message in oldMessage {
                RealmManager.shared.save(message)
            }
        }
    }
}
