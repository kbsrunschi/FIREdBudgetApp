//
//  Transaction.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/6/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Transaction: NSObject, NSCoding {
    
    // MARK: -Properties
    
    var username: String
    var merchant: String
    var category: String
    var amount: NSNumber
    var date: NSDate
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("transactions")
    
    struct PropertyKey {
        static let usernameKey = "username"
        static let merchantKey = "merchant"
        static let categoryKey = "category"
        static let amountKey = "amount"
        static let dateKey = "date"
    }
    
    // MARK: -Init
    
    init?(username: String, merchant: String, category: String, amount: NSNumber, date: NSDate) {
        self.username = username
        self.merchant = merchant
        self.category = category
        self.amount = amount
        self.date = date
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: PropertyKey.usernameKey)
        aCoder.encodeObject(merchant, forKey: PropertyKey.merchantKey)
        aCoder.encodeObject(category, forKey: PropertyKey.categoryKey)
        aCoder.encodeObject(amount, forKey: PropertyKey.amountKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey(PropertyKey.usernameKey) as! String
        let merchant = aDecoder.decodeObjectForKey(PropertyKey.merchantKey) as! String
        let category = aDecoder.decodeObjectForKey(PropertyKey.categoryKey) as! String
        let amount = aDecoder.decodeObjectForKey(PropertyKey.amountKey) as! Double
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        
        self.init(username: username, merchant: merchant, category: category, amount: amount, date: date)
    }
    
    
}