//
//  DatabaseManager.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import Firebase


class DatabaseManager {
    static let shared = DatabaseManager()
    
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
    
    func saveUserInFirestore(_ user: User) {
        do {
            try firestoreReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func downloadUserFromFirestore(userId: String) {
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
    
}
