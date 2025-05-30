//
//  User.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import Foundation

struct User{
    let uid : String
    var email: String?
    
    let isAnonymous: Bool
    
    init(uid: String, email: String? = nil, isAnonymous: Bool) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
    }
}
