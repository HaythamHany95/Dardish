//
//  SettingsTableVC.swift
//  Dardesh
//
//  Created by Haytham on 08/10/2023.
//

import UIKit

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tellFriendButton(_ sender: UIButton) {
        print("tell friend")
    }
    @IBAction func termsButton(_ sender: UIButton) {
        print("terms")
    }
    @IBAction func logOutButton(_ sender: UIButton) {
        print("logOut")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 3.0
    }
}
