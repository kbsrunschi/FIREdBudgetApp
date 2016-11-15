//
//  User.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/7/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import Foundation
import UIKit

class User:NSObject {
    
    //MARK: -Properties
    var username: String?
    var password: String?
    var isAuthenticated: Bool
    var userImage: UIImage?
    var email: String?
    var categoryLimits: [String: NSNumber]?
    
    let infoDictionary = NSBundle.mainBundle().infoDictionary!
    
    
     // MARK: -Init
    init?(username: String?, password: String?, isAuthenticated: Bool, userImage: UIImage?, email: String?, categoryLimits: [String: NSNumber]?){
        self.username = username
        self.password = password
        self.isAuthenticated = isAuthenticated
        self.userImage = userImage
        self.email = email
        self.categoryLimits = categoryLimits
        
        super.init()
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    
    struct PropertyKey {
        static let usernameKey = "username"
        static let passwordKey = "password"
        static let authKey = "isAuthenticated"
        static let categoryLimitsKey = "categoryLimits"
        static let emailKey = "email"
        static let userImageKey = "userImage"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: PropertyKey.usernameKey)
        aCoder.encodeObject(password, forKey: PropertyKey.passwordKey)
        aCoder.encodeBool(isAuthenticated, forKey: PropertyKey.authKey)
        aCoder.encodeObject(categoryLimits, forKey: PropertyKey.categoryLimitsKey)
        aCoder.encodeObject(email, forKey: PropertyKey.emailKey)
        aCoder.encodeObject(userImage, forKey: PropertyKey.userImageKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey(PropertyKey.usernameKey) as! String
        let password = aDecoder.decodeObjectForKey(PropertyKey.passwordKey) as! String
        let isAuthenticated = aDecoder.decodeBoolForKey(PropertyKey.authKey)
        let userImage = aDecoder.decodeObjectForKey(PropertyKey.userImageKey) as! UIImage
        let email = aDecoder.decodeObjectForKey(PropertyKey.emailKey) as! String
        let categoryLimits = aDecoder.decodeObjectForKey(PropertyKey.categoryLimitsKey) as! [String: NSNumber]
        
        self.init(username: username, password: password, isAuthenticated: isAuthenticated, userImage: userImage, email: email, categoryLimits: categoryLimits)
    }
    
}