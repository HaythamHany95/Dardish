//
//  MessagesDisplayDelegate.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import MessageKit

extension MessagesVC: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(tail, .pointedEdge)
    }
    
}
