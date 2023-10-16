//
//  DatabaseManager.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import Firebase


class UserFirestoreListener {
    static let shared = UserFirestoreListener()
    
    //MARK: - Login
    
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerifieed: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard error == nil, authResult?.user.isEmailVerified == true else {
                completion(error, false)
                return
            }
            completion(error, true)
            self.downloadUserFromFirestore(userId: authResult?.user.uid ?? "")
        }
    }
    //MARK: - Register
    
    func registerUserWith(email: String,username: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResults, error in
            completion(error)
            guard email == email, error == nil else { return }
            
            authResults?.user.sendEmailVerification { error in
                completion(error)
            }
            guard authResults?.user != nil else { return }
            let user = User(id: authResults?.user.uid ?? "", username: email, email: email, status: "Hey, I'm using Dardesh")
            
            self?.saveUserInFirestore(user)
            saveUserLocally(user)
        }
    }
    
    //MARK: - Resend Email Verification
    
    func resendVerificationEmailWith(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload { error in
            Auth.auth().currentUser?.sendEmailVerification { error in
                completion(error)
            }
        }
    }
    
    //MARK: - Reset Password
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    //MARK: - Log Out
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: Constants.currentUser)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    //MARK: - save user
    
    func saveUserInFirestore(_ user: User) {
        do {
            try firestoreReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - download user using ID
    
     func downloadUserFromFirestore(userId: String) {
        firestoreReference(.User).document(userId).getDocument { document, error in
            guard let userDocument = document else {
                print("no data found")
                return
            }
            
            let result = Result {
                try? userDocument.data(as: User.self)
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("document does not exist")
                }
                
            case .failure(let error):
                print("error docoding user \(error.localizedDescription)")
            }
        }
    }
    //MARK: - download all users and exepting the current one
    
    func downloadAllUsersfromFirestore(completion: @escaping (_ users: [User]?) -> Void) {
        
        var appUsers: [User] = []

        firestoreReference(.User).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("no documents found")
                return
            }
            let allUsers = documents.compactMap { snapshot -> User? in
                return try? snapshot.data(as: User.self)
            }

//for exepting the current user "Haytham" of being in the all users, and the array above for appending others only.
            for user in allUsers {
                if User.currentId != user.id {
                    appUsers.append(user)
                }
            }
            completion(appUsers)
        }
    }
    //MARK: - download users using IDs
    
    func downloadUsersfromFirestore(withIds: [String], completion: @escaping(_ allUsers: [User]) -> Void) {
        var counter = 0
        var usersArr: [User] = []
        
        for userId in withIds {
            firestoreReference(.User).document(userId).getDocument { documentSnapshot, error in
                guard let document = documentSnapshot else { return }
                let user = try? document.data(as: User.self)
                
                usersArr.append(user!)
                counter += 1
                
                if counter == withIds.count {
                    completion(usersArr)
                }
            }
        }
    }
}
