//
//  MessagesVC.swift
//  Dardesh
//
//  Created by Haytham on 15/10/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class MessagesVC: MessagesViewController {

    private var chatId = ""
    private var recipientsId = ""
    private var recipientName = ""
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientsId = recipientId
        self.recipientName = recipientName
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
