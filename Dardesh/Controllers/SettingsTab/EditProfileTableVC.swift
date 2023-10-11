//
//  EditProfileTableVC.swift
//  Dardesh
//
//  Created by Haytham on 09/10/2023.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableVC: UITableViewController {
    
    var gallery: GalleryController?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        usernameTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        showUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showUserInfo()
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        showImageGallery()
    }
    
    private func showUserInfo() {
        guard let user = User.currentUser else { return }
        usernameTextField.text = user.username
        statusLabel.text = user.status
        guard user.avatarLink != "" else { return }
        //LATER:- Set avatar image
        FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
            self.avatarImageView.image = avatarImage
        }
    }
    
    private func showImageGallery() {
        self.gallery = GalleryController()
        self.gallery?.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.initialTab = .imageTab
        Config.Camera.imageLimit = 1
        
        self.present(gallery ?? GalleryController(), animated: true)
    }
    
    private func uploadAvatarImage(_ image: UIImage) {
        let fileDirectory = "Avatars/" + "_\(User.currentId!)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            
            guard var user = User.currentUser else { return }
            user.avatarLink = avatarLink ?? ""
            saveUserLocally(user)
            DatabaseManager.shared.saveUserInFirestore(user)
        }
        
        //Save image locally
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.5)! as NSData, fileName: User.currentId!)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 0.0 : 0.5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            performSegue(withIdentifier: "goToStatus", sender: self)
        }
    }
    
}
extension EditProfileTableVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard textField == usernameTextField else { return false }
        if usernameTextField.text != "" {
            guard var user = User.currentUser else { return false }
            user.username = textField.text ?? ""
            saveUserLocally(user)
            DatabaseManager.shared.saveUserInFirestore(user)
        }
        usernameTextField.resignFirstResponder()
        return true
    }
    
}
extension EditProfileTableVC: GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
       
        guard images.count > 0 else { return }
        
        images.first?.resolve { avatarImage in
            guard avatarImage != nil else {
                
                ProgressHUD.showError("Couldn't select image")
                return
            }
            //LATER:- upload avatarImage
            self.uploadAvatarImage(avatarImage ?? UIImage())
            
            self.avatarImageView.image = avatarImage
        }
        
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
    
    
}
