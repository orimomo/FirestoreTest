//
//  PostModel.swift
//  FirestoreTest
//
//  Created by 折田桃子 on 2020/01/13.
//  Copyright © 2020 Momoko Orita. All rights reserved.
//

import Foundation

class PostModel {
    let message: String
    let createdAt: Date
    
    init(document: [String: Any]) {
        message = document["message"] as? String ?? ""
        createdAt = document["createdAt"] as? Date ?? Date()
    }
}
