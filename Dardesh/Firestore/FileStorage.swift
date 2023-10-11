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
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if isFileExistAtPath(path: imageFileName) {
            // get it localy
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)) {
                completion(contentsOfFile)
            } else {
                print("couldn't convert image")
                completion(UIImage(named: "avatar") ?? UIImage())
            }
            
        } else {
            // download from firestore
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    }
                }
                
            } else {
                print("no document found in database")
                completion(nil)
            }
        }
        
    }
    
    //MARK: - Save file locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}

//MARK: Helpers Functionallity for saving file

func getDocumentUrl() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileInDocumentDirectory(fileName: String) -> String {
    return getDocumentUrl().appendingPathComponent(fileName).path
}

func isFileExistAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentDirectory(fileName: path))
}
