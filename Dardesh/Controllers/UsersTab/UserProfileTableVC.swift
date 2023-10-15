//
//  UserProfileTableVC.swift
//  Dardesh
//
//  Created by Haytham on 12/10/2023.
//

import UIKit

class UserProfileTableVC: UITableViewController {
    
    var user: User?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.contentMode = .scaleAspectFill
        navigationItem.largeTitleDisplayMode = .never
        
        setupUI()
    }
    
    private func setupUI() {
       guard user != nil else { return }
        
        self.title = user?.username
        usernameLabel.text = user?.username
        statusLabel.text = user?.status
        
        guard user?.avatarLink != ""  else { return }
        FileStorage.downloadImage(imageUrl: user!.avatarLink) { avatarImage in
            self.avatarImageView.image = avatarImage
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 0.0 : 5.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            print("start chat")
            // saving chatRoom in firestore
            let chatRoomId = startChat(sender: User.currentUser!, receiver: user!)
            //navigate to messagesVC to make the chat
            let vc = MessagesVC(chatId: chatRoomId, recipientId: user!.id, recipientName: user!.username)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


