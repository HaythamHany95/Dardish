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
    var mkMessages: [MKMessage] = []
    
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    
    var notificationToken: NotificationToken?
    
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
        
        loadMessages()
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.refreshControl = refreshControl
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
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
        Outgoing.sendMessage(chatId: chatId, memberIds: [User.currentId!, recipientsId], text: text, video: video, audio: audio, image: image, location: location)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    //MARK: - Load Messages
    
    private func loadMessages() {
        allLocalMessages = realm.objects(LocalMessage.self).filter("chatRoom = %@", chatId).sorted(byKeyPath: "date", ascending: true)
        print("\(allLocalMessages.count) message found")
        //insertMkMessages()
        
        if allLocalMessages.isEmpty {
            checkForOldMessage()
        }
        ///Observing any change in RealmDataBase "LocalMessages"
        notificationToken = allLocalMessages.observe({ (change: RealmCollectionChange) in
            switch change {
            
            case .initial:
                self.insertMkMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMkMessage(localMessage: self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            
            case .error(let error):
                print("error in insertion", error.localizedDescription)
            }
        })
        
    }
    
    //Converting the localMessage to mKMessage to append it to mkMessages array that responsible to display the chat
    private func insertMkMessage(localMessage: LocalMessage) {
        let incoming = Incoming(messageViewController: self)
        
        let mKMessage = incoming.createMkMessage(localMessage: localMessage)
        self.mkMessages.append(mKMessage)

    }
    
    private func insertMkMessages() {
        for localMessage in allLocalMessages {
            insertMkMessage(localMessage: localMessage)
            
        }
    }
    
    private func checkForOldMessage() {
        MessageFirestoreListener.shared.checkForOldMessage(documentId: User.currentId!, collectionId: chatId)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
