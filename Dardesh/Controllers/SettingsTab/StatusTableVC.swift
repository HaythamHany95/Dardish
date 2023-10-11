//
//  StatusTableVC.swift
//  Dardesh
//
//  Created by Haytham on 11/10/2023.
//

import UIKit

class StatusTableVC: UITableViewController {

    let statusArr = ["Available", "Busy", "At School", "At The Movies", "At Work", "Battery about to die", "In a Meeting", "Can't Talk", "At The Gym", "Sleeping", "Urgent calls only" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userStatus = tableView.cellForRow(at: indexPath)?.textLabel?.text
        tableView.reloadData()
        
        guard var user = User.currentUser else { return }
        user.status = userStatus ?? "Hey I'm using Dardish"
        saveUserLocally(user)
        DatabaseManager.shared.saveUserInFirestore(user)
        
    }

}
extension StatusTableVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath)
        cell.textLabel?.text = statusArr[indexPath.row]
        let userStatus = User.currentUser?.status
        cell.accessoryType = userStatus == statusArr[indexPath.row] ? .checkmark : .none
        return cell
    }
}
