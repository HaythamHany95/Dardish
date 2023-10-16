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
}
