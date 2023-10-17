//
//  InputBarAccessoryViewDelegate.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import InputBarAccessoryView

extension MessagesVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        print("typing \(text)")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text: text, image: nil, video: nil, location: nil, audio: nil)
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
        
    }
}
