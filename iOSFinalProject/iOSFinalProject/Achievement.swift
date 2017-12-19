//
//  Achievement.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 12/17/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class Achievements {
    

    
        static func check() {
        
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        let todaysDate = Date()
        let todaysDateRef = ref.child(user!.uid).child(g_dateFormatter.string(from: todaysDate))

    }
}
