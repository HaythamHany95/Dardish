//
//  ViewController.swift
//  Dardesh
//
//  Created by Haytham on 04/10/2023.
//

import UIKit
import ProgressHUD

class LoginVC: UIViewController {
    
    var isLogin: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var haveAccountLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var resendEmail: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var login: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
    }
    
    @IBAction func resendEmailButton(_ sender: UIButton) {
        resendVerificationEmail()
    }
    
    @IBAction func forgetPasswordButton(_ sender: UIButton) {
        if isFieldHasUserInfo(view: "forget Password") {
            print("all fields are set up")
            resetPassword()
        } else {
            print("all fields are required")
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        if isFieldHasUserInfo(view: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
            
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        updateUI(mode: isLogin)
        if isFieldHasUserInfo(view: isLogin ? "login" : "register") {
            print("all fields are set up")
            // TO DO : Login
        } else {
            print("all fields are required")
            ProgressHUD.showError("All fields are required")
        }
    }
    
    private func customizeUI() {
        emailLabel.text = nil
        passwordLabel.text = nil
        confirmPasswordLabel.text = nil
        forgetPassword.isHidden = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func updateUI(mode: Bool) {
        if !mode {
            titleLabel.text = "Login"
            confirmPasswordTextField.isHidden = true
            resendEmail.isHidden = true
            register.setTitle("Login", for: .normal)
            haveAccountLabel.text = "New here?"
            login.setTitle("Register", for: .normal)
            forgetPassword.isHidden = false
            
        } else {
            titleLabel.text = "Register"
            confirmPasswordTextField.isHidden = false
            resendEmail.isHidden = false
            forgetPassword.isHidden = true
            register.setTitle("Register", for: .normal)
            login.setTitle("Login", for: .normal)
        }
        isLogin.toggle()
    }
    
    private func isFieldHasUserInfo(view: String) ->Bool {
        switch view {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
            
        case "register":
            return emailTextField.text != "" && passwordTextField.text != "" &&
            confirmPasswordTextField.text != ""
            
        case "forget Password":
            return emailTextField.text != ""
            
        default:
            return false
        }
    }
    
    private func registerUser() {
        guard passwordTextField.text == confirmPasswordTextField.text else { return }
        
        UserFirestoreListener.shared.registerUserWith(email: emailTextField.text ?? "", username: emailTextField.text ?? "", password: passwordTextField.text ?? "") { error in
            
            guard error == nil else {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            ProgressHUD.showSucceed("Verification email sent, please verify your email and confirm registeration")
        }
    }
    
    private func loginUser() {
        UserFirestoreListener.shared.loginUserWith(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        { error, isEmailVerifieed in
            if error == nil {
                
                if isEmailVerifieed {
                    print("login successeded")
                    self.goToApp()
                } else {
                    ProgressHUD.showError("Please check your email and verify your registeration")
                }
                
                
            } else {
                ProgressHUD.showFailed(error?.localizedDescription)
            }
            
        }
    }
    
    private func goToApp() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.mainVC) as? MainVC
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: false)
    }
    
    private func resendVerificationEmail() {
        UserFirestoreListener.shared.resendVerificationEmailWith(email: emailTextField.text ?? "") { error in
            if error == nil {
                ProgressHUD.showSucceed("Verification email sent successfully")
            } else {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
    }
    
    private func resetPassword() {
        UserFirestoreListener.shared.resetPasswordFor(email: emailTextField.text ?? "") { error in
            if error == nil {
                ProgressHUD.showSucceed("Reset email has been sent successfully")
            } else {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        emailLabel.text = emailTextField.hasText ? "Email" : ""
        passwordLabel.text = passwordTextField.hasText ? "Password" : ""
        confirmPasswordLabel.text = confirmPasswordTextField.hasText ? "Confirm Password" : ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            registerUser()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


