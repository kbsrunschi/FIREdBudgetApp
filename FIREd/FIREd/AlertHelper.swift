//
//  AlertHelper.swift
//  FIREd
//
//  Created by Kathryn Smith on 8/24/16.
//  Copyright © 2016 Kathryn Smith. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    
    func showAlert(title: String, message: String, fromController controller: UITableViewController, log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showVCAlert(title: String, message: String, fromController controller: UIViewController, log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showOKAlert(title: String, message: String, log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
         UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showPremiumAlert(title: String, message:String, log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        let buyAction = UIAlertAction(title:"Upgrade", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
        alertController.addAction(buyAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func showPremiumTCAlert(title: String, message:String, fromController controller: UITableViewController,log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        let buyAction = UIAlertAction(title:"Upgrade", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
        alertController.addAction(buyAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func showCancelAlert(title: String, message:String, log: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in NSLog(log)
        })
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
}