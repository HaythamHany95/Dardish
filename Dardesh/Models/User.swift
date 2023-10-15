//
//  User.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var status: String
    var avatarLink = ""
    var pushID = ""
    
    static var currentId: String? {
        
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let data = UserDefaults.standard.data(forKey: Constants.currentUser) {
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: data)
                    return userObject
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: Constants.currentUser)
    } catch {
        print(error.localizedDescription)
    }
}

//func createDummyUsers() {
//    print("creating dummy users")
//
//    let names = ["Ammar", "Elmemy", "Abdelkader", "AbdelHalem" , "Om Kalthom"]
//
//    var imageIndex = 1
//    var userIndex = 1
//
//    for i in 0..<5 {
//        let id = UUID().uuidString
//        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
//
//        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { avatarLink in
//            let user = User(id: id, username: names[i], email: "\(names[i])@gmail.com", status: "No Status", avatarLink: avatarLink ?? "", pushID: "")
//
//            userIndex += 1
//            DatabaseManager.shared.saveUserInFirestore(user)
//        }
//
//        imageIndex += 1
//        if imageIndex == 5 {
//            imageIndex = 1
//        }
//    }
//}
