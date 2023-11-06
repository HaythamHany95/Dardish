//
//  TypingFirestoreListener.swift
//  Dardesh
//
//  Created by Haytham on 22/10/2023.
//

import Foundation
import Firebase

class TypingFirestoreListener {
    static let shared = TypingFirestoreListener()
    
    var typingListener: ListenerRegistration!
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingListener = firestoreReference(.Typing).document(chatRoomId).addSnapshotListener { documentSnapshot, error in
            
            guard let snapshot = documentSnapshot else { return }
           
            if snapshot.exists {
               
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        
                        completion(data.value as! Bool)
                    }
                }
                
            } else {
                completion(false)
                firestoreReference(.Typing).document(chatRoomId).setData([User.currentId! : false])
            }
        }
    }
    
    func saveTypingCounter(typing: Bool, chatRoomId: String) {
        firestoreReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
    }
    
    ///Stop listeners is important for not using device resource for nothing
    func removeTypingListener() {
        typingListener.remove()
    }
}
