//
//  ChatTableViewCell.swift
//  Dardesh
//
//  Created by Haytham on 13/10/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unreadMessageLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var unreadMessageView: UIView!
    @IBOutlet weak var unreadedCounterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.contentMode = .scaleAspectFill
        unreadMessageView.layer.cornerRadius = 15
    }
    
    func configureChatCell(chatRoom: ChatRoom) {
        usernameLabel.text = chatRoom.receiverName
        unreadMessageLabel.text = chatRoom.lastMessage
        
        if chatRoom.unreadCounter != 0 {
            unreadedCounterLabel.text = String(chatRoom.unreadCounter)
            unreadMessageView.isHidden = false
        } else {
            unreadMessageView.isHidden = true
        }
        if chatRoom.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: chatRoom.avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
        
        messageTimeLabel.text = timeElapsed(chatRoom.date!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
