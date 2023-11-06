//
//  SceneDelegate.swift
//  Dardesh
//
//  Created by Haytham on 04/10/2023.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var authListener: AuthStateDidChangeListenerHandle?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        autoLogin()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
    }
    
    func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            guard user != nil, UserDefaults.standard.object(forKey: Constants.currentUser) != nil else { return }
            DispatchQueue.main.async {
                self.goToApp()
            }
        }
    }
    
    private func goToApp() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.mainVC) as? MainVC
        self.window?.rootViewController = vc
        vc?.modalPresentationStyle = .fullScreen
        
    }
    
}
