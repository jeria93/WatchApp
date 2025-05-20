//
//  User.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import Foundation

struct User {
    let uid : String
    
    let isAnonymous: Bool
    
    init(uid: String, isAnonymous: Bool) {
        self.uid = uid
        self.isAnonymous = isAnonymous
    }
}
