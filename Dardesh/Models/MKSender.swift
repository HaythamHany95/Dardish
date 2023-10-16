//
//  MessageKitSender.swift
//  Dardesh
//
//  Created by Haytham on 16/10/2023.
//  MK = MessageKit

import Foundation
import MessageKit
import UIKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
    
}
