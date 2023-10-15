//
//  FirestoreCollectionReference.swift
//  Dardesh
//
//  Created by Haytham on 05/10/2023.
//

import Foundation
import Firebase

enum FirestoreCollection: String {
    case User
    case Chat
}

func firestoreReference(_ collectionReference: FirestoreCollection) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

