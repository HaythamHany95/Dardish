//
//  IncomingMessage.swift
//  Dardesh
//
//  Created by Haytham on 17/10/2023.
//

import Foundation
import MessageKit

class Incoming {
    var messageViewController: MessagesViewController
    
    init(messageViewController: MessagesViewController) {
        self.messageViewController = messageViewController
    }
    
    func createMkMessage(localMessage: LocalMessage) -> MKMessage {
        let mkMessage = MKMessage(message: localMessage)
        return mkMessage
    }
}
