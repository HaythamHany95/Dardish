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
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.contentMode = .scaleAspectFill
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showUserInfo()
    }
    @IBAction func tellFriendButton(_ sender: UIButton) {
        print("tell friend")
    }
    
    @IBAction func termsButton(_ sender: UIButton) {
        print("terms")
    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        //LATER:- Alert Controller before sign out
        UserFirestoreListener.shared.logOutCurrentUser { error in
            guard error == nil else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboarding") as? LoginVC
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc ?? UIViewController(), animated: false)
        }
    }
    
    private func showUserInfo() {
        guard let user = User.currentUser else { return }
        usernameLabel.text = user.username
        statusLabel.text = user.status
        appVersionLabel.text = Constants.appVersion
        
        guard user.avatarLink != "" else { return }
        FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
            self.avatarImageView.image = avatarImage
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 3.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 0 {
            performSegue(withIdentifier: "goToEditProfile", sender: self)
        }
    }
    
}
