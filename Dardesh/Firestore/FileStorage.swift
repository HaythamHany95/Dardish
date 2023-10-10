//
//  FileStorage.swift
//  Dardesh
//
//  Created by Haytham on 10/10/2023.
//

import Foundation
import UIKit
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        //1. create folder on firestore
        let storageRef = storage.reference(forURL: Constants.parantDirectoryStorageReference).child(directory)
       
        //2. convert image to data
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        //3. put data into firestore and return the link
        var task: StorageUploadTask?
        
        task = storageRef.putData(imageData!) { metadata, error in
            
            task!.removeAllObservers()
            ProgressHUD.dismiss()
            
            guard error == nil else {
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        }
        
        //4. observe percentage upload
        task?.observe(StorageTaskStatus.progress) { snapshot in
            let progress = (snapshot.progress?.completedUnitCount ?? Int64(0.0)) / (snapshot.progress?.totalUnitCount ?? Int64(0.0))
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
}
