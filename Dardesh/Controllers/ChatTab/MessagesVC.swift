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
    
    var displayingMessagesCount = 0
    var maxMessagesNumber = 0
    var minMessagesNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController!
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientsId = recipientId
        self.recipientName = recipientName
    }
    
    //MARK: - Declaration LeftBarButton View
    
    private let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        return view
    }()
    
    private let recipientTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let chatStatusLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 21, width: 100, height: 25))
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        configureMessageCollectionView()
        configureMessageInputBar()
        configureCustomTitle()
        
        loadMessages()
        listenToNewMessages()
        createTypingOserver()
        listenToReadStatusUpdates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - UI costomize functionality
    
    private func configureCustomTitle() {
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTap)), UIBarButtonItem(customView: leftBarButtonView)]
        
        leftBarButtonView.addSubview(recipientTitleLabel)
        leftBarButtonView.addSubview(chatStatusLabel)
        
        recipientTitleLabel.text = recipientName
    }
    
    @objc private func backButtonTap() {
        removeListener()
        ChatRoomFirestoreListener.shared.clearUnreadCounterWith(chatRoomId: chatId)
        navigationController?.popViewController(animated: true)
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
        attachButton.onTouchUpInside { [weak self] item in
            print("attaching item")
            
            guard let strongSelf = self else { return }
            strongSelf.actionAttachMessage()
            
        }
        
        //let micButton = InputBarButtonItem()
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        ///ADD Getsure Recognizer and positin tems in the stacks
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        //TODO: update micButton status
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.backgroundColor = .systemBackground
        
        
    }
    
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    //MARK: - Mark message as "read"
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId {
            MessageFirestoreListener.shared.updateMessageStatus(localMessage, userId: recipientsId)
        }
    }
    
    //MARK: - Update Typing Indicator
    
    func updateChatStatusIndicator(show: Bool) {
        chatStatusLabel.text = show ? "Typing..." : ""
    }
    
    func startTypingIndicator() {
        
        typingCounter += 1
        TypingFirestoreListener.shared.saveTypingCounter(typing: true, chatRoomId: chatId)
        ///Stop typing after 1.5 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopTypingIndicator()
        }
    }
    
    func stopTypingIndicator() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            TypingFirestoreListener.shared.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    ///Listen to other user typing status
    func createTypingOserver() {
        TypingFirestoreListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
            
            DispatchQueue.main.async {
                self.updateChatStatusIndicator(show: isTyping)
            }
        }
    }
    
    //MARK: - Actions
    
    func send(text: String?, image: UIImage?, video: Video?,location: String?, audio: String?, audioDuration: Float = 0.0) {
        Outgoing.sendMessage(chatId: chatId, memberIds: [User.currentId!, recipientsId], text: text, video: video, audio: audio, image: image, location: location)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    private func actionAttachMessage() {
        
        messagesCollectionView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { [weak self] alert in
            self?.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) { [weak self] alert in
            self?.showImageGallery(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { [weak self] alert in
                self?.send(text: nil, image: nil, video: nil, location: Constants.locationType, audio: nil)
           
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName:"mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancel)
        
        present(optionMenu, animated: true)
        
    }
    
    //MARK: - Gallery :
    
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        
        gallery.delegate = self
        
        Config.initialTab = .imageTab
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.VideoEditor.maximumDuration = 30
        
        present(gallery, animated: true)
    }
    
    //MARK: - UI scroll view delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing{
            
            if displayingMessagesCount < allLocalMessages.count {
                insertMoreMkMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
        refreshControl.endRefreshing()
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
    
    //MARK: - Insert MKMessage
    
    ///Converting the localMessage to mKMessage to append it to mkMessages array that responsible to display the chat
    private func insertMkMessage(localMessage: LocalMessage) {
        markMessageAsRead(localMessage)
        let incoming = Incoming(messageViewController: self)
        
        let mKMessage = incoming.createMkMessage(localMessage: localMessage)
        self.mkMessages.append(mKMessage)
        
        displayingMessagesCount += 1
    }
    
    ///When user pull up to load more messages "The Old Messages"
    private func insertOlderMkMessage(localMessage: LocalMessage) {
        let incoming = Incoming(messageViewController: self)
        
        let mKMessage = incoming.createMkMessage(localMessage: localMessage)
        self.mkMessages.insert(mKMessage, at: 0)
        
        displayingMessagesCount += 1
    }
    
    private func insertMkMessages() {
        maxMessagesNumber = allLocalMessages.count - displayingMessagesCount
        minMessagesNumber = maxMessagesNumber - Constants.numberOfMessages
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in minMessagesNumber ..< maxMessagesNumber {
            insertMkMessage(localMessage: allLocalMessages[i])
        }
        
    }
    ///When user pull up to load more messages "The Old Messages"
    private func insertMoreMkMessages() {
        maxMessagesNumber = minMessagesNumber - 1
        minMessagesNumber = maxMessagesNumber - Constants.numberOfMessages
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in (minMessagesNumber ... maxMessagesNumber).reversed() {
            insertOlderMkMessage(localMessage: allLocalMessages[i])
        }
        
    }
    
    //MARK: - Get the old messages
    
    private func checkForOldMessage() {
        MessageFirestoreListener.shared.checkForOldMessage(documentId: User.currentId!, collectionId: chatId)
    }
    
    //MARK: - Listen to new messages
    
    private func listenToNewMessages() {
        MessageFirestoreListener.shared.listenToNewMessages(documentId: User.currentId!, collectionId: chatId, lastMessageDate: determineLastMessageDate())
    }
    
    private func determineLastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    //MARK: - Update Read Status
    
    private func updateReadMessage(_ updatedLocalMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            
            let tempMessage = mkMessages[index]
            
            if updatedLocalMessage.id == tempMessage.messageId {
                
                mkMessages[index].status = updatedLocalMessage.status
                mkMessages[index].readDate = updatedLocalMessage.readDate
                
                RealmManager.shared.save(updatedLocalMessage)
                
                if mkMessages[index].status == "✔️✔️" {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func listenToReadStatusUpdates() {
        
        MessageFirestoreListener.shared.listenForReadStatus(documentId: User.currentId!, collectionId: chatId) { updatedMessage in
            self.updateReadMessage(updatedMessage)
        }
    }
    
    
    //MARK: - Helpers
    ///Stop listeners is important for not using device resource for nothing
    private func removeListener() {
        TypingFirestoreListener.shared.removeTypingListener()
        MessageFirestoreListener.shared.removeNewMessageListener()
    }
    
}
