//
//  MessagesLayoutDelegate.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import MessageKit

extension MessagesVC: MessagesLayoutDelegate {
    
    //MARK: - Cell top label
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 3 == 0 {
            
            if indexPath.section == 0 && displayingMessagesCount < allLocalMessages.count {
                return 40
            }
        }
        return 15
        
    }
    
    //MARK: - Avatar view
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.set(avatar: Avatar(image: nil, initials: mkMessages[indexPath.section].senderInitials))
    }
    
    //MARK: - Message bottom label
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return indexPath.section != mkMessages.count - 1 ? 13 : 0
        
    }
    
    //MARK: - Cell bottom label
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return isFromCurrentSender(message: message) ? 17 : 0
        
    }
    
}
