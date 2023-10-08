//
//  User.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    var id = ""
    var username: String
    var email: String
    var status: String
    var avatarLink = ""
    var pushID = ""
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
