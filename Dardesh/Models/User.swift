//
//  User.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable {
    var id = ""
    var username: String
    var email: String
    var status: String
    var avatarLink = ""
    var pushID = ""
    
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
