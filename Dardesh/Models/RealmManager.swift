//
//  RealmManager.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    let realm = try! Realm()
    
    func save<T: Object> (_ object: T) {
        do {
            try realm.write{
                realm.add(object, update: .all)
            }
        } catch {
            print("Error saving data \(error.localizedDescription)")
        }
    }
    
    
}
