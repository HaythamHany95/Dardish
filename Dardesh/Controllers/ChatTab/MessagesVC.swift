//
//  MessagesVC.swift
//  Dardesh
//
//  Created by Haytham on 15/10/2023.
//  MK = MessageKit

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class MessagesVC: MessagesViewController {
    
    private var chatId = ""
    private var recipientsId = ""
    private var recipientName = ""
    let refreshControl = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    let currentUser = MKSender(senderId: User.currentId!, displayName: User.currentUser!.username)
    let mkMessages: [MKMessage] = []
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientsId = recipientId
        self.recipientName = recipientName
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.dataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.refreshControl = refreshControl
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "paperclip", withConfiguration:UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("attaching item")
            //TODO: attach action
        }
        
        //let micButton = InputBarButtonItem()
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //ADD Getsure Recognizer and positining items in the stacks
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        //TODO: update micButton status
        updateMicButtonStatus(show: false)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.backgroundColor = .systemBackground
        
        
    }
    
    private func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    

    //ACTIONS
    func send(text: String?, image: UIImage?, video: Video?,location: String?, audio: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.sendMessage(chatId: chatId, memberIds: [User.currentId!, recipientsId], text: text, video: video, audio: audio, image: image, location: location)
    }
    
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
