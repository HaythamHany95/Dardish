//
//  ChatsTableVC.swift
//  Dardesh
//
//  Created by Haytham on 13/10/2023.
//

import UIKit

class ChatsTableVC: UITableViewController {
    var allChatRooms: [ChatRoom] = []
    var filteredChatRooms: [ChatRoom] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applySearchController()
        downloadChatRooms()
    }
    
    @IBAction func composeChat(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "users") as! UsersTableVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func applySearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Chats"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self ///delegate
    }
    
    private func downloadChatRooms() {
        ChatRoomFirestoreListener.shared.downloadChatRooms { allFSChatRooms in
            self.allChatRooms = allFSChatRooms
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func navigateToMessages(chatRoom: ChatRoom) {
        //TODO: make sure that both users have the chatRoom
        recreateChatRoom(chatRoomId: chatRoom.chatRoomId, memberIds: chatRoom.memberIds)
        
        let vc = MessagesVC(chatId: chatRoom.chatRoomId, recipientId: chatRoom.receiverId, recipientName: chatRoom.receiverName)
        navigationController?.pushViewController(vc, animated: true)
    }
    
//MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredChatRooms.count : allChatRooms.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        cell.configureChatCell(chatRoom: searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row])
    
        return cell
    }
    
    //MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("chat deleted")
        ChatRoomFirestoreListener.shared.deleteChatRoom(chatRoom: allChatRooms[indexPath.row])
        searchController.isActive ? filteredChatRooms.remove(at: indexPath.row) : allChatRooms.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomObject = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        navigateToMessages(chatRoom: chatRoomObject)
    }
    
}
extension ChatsTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredChatRooms = allChatRooms.filter { chatRoom in
            return chatRoom.receiverName.lowercased().contains((searchController.searchBar.text?.lowercased())!)
        }
        tableView.reloadData()
    }
}
