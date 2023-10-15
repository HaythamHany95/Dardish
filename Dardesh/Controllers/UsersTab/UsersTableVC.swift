//
//  UsersTableVC.swift
//  Dardesh
//
//  Created by Haytham on 12/10/2023.
//

import UIKit

class UsersTableVC: UITableViewController {
    
    var appUsersArr: [User] = []
    var filterdUsersArr: [User] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        applySearchController()
        applyRefreshControl()
        ///appUsersArr = [User.currentUser!]
        ///createDummyUsers()
        downloadAppUsers()
      
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadAppUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    
    func applyRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
    }
    
    func applySearchController() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = true
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Users"
    definesPresentationContext = true
    searchController.searchResultsUpdater = self ///delegate
}
    
    private func downloadAppUsers() {
        UserFirestoreListener.shared.downloadAllUsersfromFirestore { appUsers in
            self.appUsersArr = appUsers!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: -  TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filterdUsersArr.count : appUsersArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        let user = searchController.isActive ? filterdUsersArr[indexPath.row] : appUsersArr[indexPath.row]
        
        cell.configureUserCell(user: user)
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let user = searchController.isActive ? filterdUsersArr[indexPath.row] : appUsersArr[indexPath.row]
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userProfile") as! UserProfileTableVC
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension UsersTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterdUsersArr = appUsersArr.filter { user in
            return user.username.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "")
        }
        tableView.reloadData()
    }

}
