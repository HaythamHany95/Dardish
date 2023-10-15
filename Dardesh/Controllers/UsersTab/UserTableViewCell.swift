//
//  UserTableViewCell.swift
//  Dardesh
//
//  Created by Haytham on 12/10/2023.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.contentMode = .scaleAspectFill
        
    }
    
    func configureUserCell(user: User) {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        if user.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
}


