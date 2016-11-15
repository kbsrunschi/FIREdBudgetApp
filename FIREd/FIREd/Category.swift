//
//  Category.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/28/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import Foundation
import UIKit

class Category: NSObject {
    
    // MARK: -Properties
    
    var name: String
    var amount: String
    var image: UIImage?
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("categories")
    
    struct PropertyKey {
        static let nameKey = "name"
        static let amountKey = "amount"
        static let imageKey = "image"
    }
    
    init?(name: String, amount: String, image: UIImage) {
        self.name = name
        self.amount = amount
        self.image = image
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(amount, forKey: PropertyKey.amountKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let amount = aDecoder.decodeObjectForKey(PropertyKey.amountKey) as! String
        let image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as! UIImage
        
        self.init(name: name, amount: amount, image: image)
    }
    
}